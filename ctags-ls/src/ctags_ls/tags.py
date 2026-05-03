from collections.abc import Mapping, Sequence
from dataclasses import dataclass
import os
from pathlib import Path
import re
from typing import final

TAGS_PATH = Path('tags')

@final
class Tags:
    def __init__(self, tags_path: Path = TAGS_PATH) -> None:
        self._last_mtime: float = 0.0
        self._cache: dict[str, list[Tag]] = {}
        self.TAGS_PATH = tags_path

    @property
    def symbols(self) -> Mapping[str, Sequence[Tag]]:
        self._assure_valid_cache()
        return self._cache

    def _assure_valid_cache(self) -> None:
        curr_mtime = os.path.getmtime(self.TAGS_PATH)
        if curr_mtime > self._last_mtime:
            self._update_cache()
            self._last_mtime = curr_mtime

    def _update_cache(self):
        self._cache = {}
        with self.TAGS_PATH.open('r') as f:
            lines = (l for l in f.readlines() if not l.startswith('!_') and not l.startswith('__anon'))
            for line in lines:
                symbol, file, location, type, *_ = line.split('\t')
                location = location.removesuffix(';"')
                if is_int(location):
                    location = int(location)
                else:
                    location = (
                        location
                        .removesuffix("/")
                        .removesuffix("$")
                        .removeprefix("/^")
                        .replace("\\\\", "\\")
                        .replace("\\/", "/")
                    )
                    location = re.compile(f'^{re.escape(location)}')
                l = self._cache.get(symbol, [])
                l.append(Tag(
                    symbol=symbol,
                    file=Path(file),
                    location=location,
                    type=type.strip()
                ))
                self._cache[symbol] = l


def is_int(s: str) -> bool:
    if not s:
        return False
    if s[0] in '+-':
        return s[1:].isdecimal() and len(s) > 1
    return s.isdecimal()

@dataclass(slots=True, frozen=True)
class Tag:
    symbol: str
    file: Path
    location: re.Pattern[str] | int
    type: str
