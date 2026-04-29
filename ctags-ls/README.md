# language server for ctags

Initial version is written in python.

The goal of this is for the language server to detect changes in a ctags file
in the pwd, and update the internal representation of the code based on that.

No automatic calling of ctags, the user is responsible for keeping it updated
as and when they like.

Hope to sort all possible go to definitions somewhat intelligently based on the
current path of the file.

Fuzzy completions?

Built with [pygls](https://github.com/openlawlibrary/pygls).
