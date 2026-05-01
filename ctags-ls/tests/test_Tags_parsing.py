
import re
from pathlib import Path
from ctags_ls.tags import Tags


# TODO: generate the tags file dynamically as preperation to the test.
def test_parsing():
    tags_path = Path(__file__).parent.resolve() / 'tags'
    tags = Tags(tags_path=tags_path)
    for tags in tags.symbols.values():
        for tag in tags:
            assert len(tag.type) == 1
            assert tag.file.is_file()
            text = tag.file.read_text()
            if isinstance(tag.location, re.Pattern):
                assert next(tag.location.finditer(text), None) is not None, f'{tag.location.pattern} has no matches in {tag.file}'
            else:
                assert text.count('\n') >= tag.location
