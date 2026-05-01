from pygls.lsp.server import LanguageServer
from lsprotocol import types

from ctags_ls.tags import Tags

ls = LanguageServer("ctags-ls", "v0.1")
tags = Tags(ls)

@ls.feature(
    types.TEXT_DOCUMENT_COMPLETION,
    types.CompletionOptions(trigger_characters=["."])
)
def completions(params: types.CompletionParams):
    items = [
        types.CompletionItem(label=symbol, documentation=f'***{tag.type}*** **{tag.location}** {tag.file}')
        for symbol, tags in tags.symbols.items()
        for tag in tags
    ]
    document = ls.workspace.get_text_document(params.text_document.uri)
    current_line = document.lines[params.position.line][:params.position.character]
    if current_line.endswith("hello."):
        items = [
            types.CompletionItem(label="world"),
            types.CompletionItem(label="friend"),
        ]
    return types.CompletionList(is_incomplete=False, items=items)

def main():
    ls.start_io()
