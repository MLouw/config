syntax on

" Write when we :make
set autowrite

" Read when someone else makes changes (iff we haven't made any ourselves)
set autoread

colorscheme torte

" Indentation!
set expandtab
set tabstop=4
set softtabstop=4
set shiftround
set autoindent
set smartindent

autocmd BufNewFile,BufRead *.lhs setlocal filetype=lhs textwidth=80

filetype indent plugin on

set pastetoggle=<F12>
