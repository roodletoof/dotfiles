if exists("current_compiler") | finish | endif
let current_compiler = "basedpyright"
let s:cpo_save = &cpo
set cpo&vim

CompilerSet makeprg=basedpyright
CompilerSet errorformat=
      \%E%f:%l:%c\ -\ error:\ %m,
      \%W%f:%l:%c\ -\ warning:\ %m,
      \%N%f:%l:%c\ -\ note:\ %m,
      \%C[\ \t]\ %.%#,
      \%-G%.%#

let &cpo = s:cpo_save
unlet s:cpo_save
