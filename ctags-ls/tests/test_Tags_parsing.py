
import re
from pathlib import Path
from ctags_ls.tags import Tag, Tags
import pytest


tags_path = Path(__file__).parent.resolve() / 'tags'
tags = (tag for tags in Tags(tags_path=tags_path).symbols.values() for tag in tags)

@pytest.mark.parametrize("tag", tags)
def test_tag(tag: Tag):
    assert len(tag.type) == 1
    assert tag.file.is_file()
    text = tag.file.read_text()
    if isinstance(tag.location, re.Pattern):
        assert next(tag.location.finditer(text), None) is not None, f'{tag.location.pattern} has no matches in {tag.file}'
    else:
        assert text.count('\n') >= tag.location
        assert tag.symbol in text.splitlines()[tag.location-1]
