" Stop highlighting unescaped underscores in the middle of a word as an error.
"
" Consistency is key, and with the way things are now, people are more likely
" to remove escaping instead of introducing it.
"
" While the original Markdown spec treats underscores in the middle of a word
" as an emphasis [1], only 2 out of 28 implementations treat it that way
" instead of treating it as a literal underscore at the time of writing [2].
" Of the 2, Pandoc only does so in an opt-in strict mode. Prettier, a popular
" formatter for Markdown, even unescapes them [3].
"
" While there are currently no settings to unhighlight individual errors [4]
" [5], this fix takes care not to unhighlight any other errors that might get
" added in the future [6].
"
" [1]: https://daringfireball.net/projects/markdown/syntax#em
" [2]: https://babelmark.github.io/?text=foo_bar_baz
" [3]: https://github.com/prettier/prettier/issues/3728
" [4]: https://github.com/tpope/vim-markdown/issues/21
" [5]: $VIMRUNTIME/syntax/markdown.vim (jump to file with gf)
" [6]: See :help :syn-transparent
syn match markdownIgnore "\w\@<=_\w\@=" transparent contains=NONE
syn cluster markdownInline add=markdownIgnore
