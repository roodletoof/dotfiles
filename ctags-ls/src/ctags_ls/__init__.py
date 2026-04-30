from dataclasses import dataclass
from pathlib import Path
from typing import final
from pygls.lsp.server import LanguageServer
from lsprotocol import types

ls = LanguageServer("ctags-ls", "v0.1")

@ls.feature(
    types.TEXT_DOCUMENT_COMPLETION,
    types.CompletionOptions(trigger_characters=["."])
)
def completions(params: types.CompletionParams):
    items = [
        types.CompletionItem(label="foo"),
        types.CompletionItem(label="bar"),
        types.CompletionItem(label="baz"),
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

@final
class Tags:
    def __init__(self) -> None:
        self.last_mtime: int = 0
        self.cache: dict[str, Tag] = {}

@dataclass
class Tag:
    symbol: str
    file: Path
    search_pattern: str
    type: types.CompletionItemKind
