set nocompatible
set noswapfile
set nobackup
set nowritebackup
syntax on
set termguicolors
highlight Normal guifg=#f2f4f8 guibg=NONE                               " Default text
highlight LineNr guifg=#525253 guibg=NONE                               " Gutter / line numbers
highlight Keyword guifg=#8D5DC7 gui=bold guibg=NONE             " Keywords
highlight CursorLineNr guifg=#f2f4f8 gui=bold guibg=NONE " Current line number (optional, makes it stand out)
highlight Comment guifg=#525253 gui=bold guibg=NONE

set autoindent
set tabstop=3
set shiftwidth=3
set relativenumber

" live character counter
function! CharCount()
   let l:count = strlen(join(getline(1, '$'), "\n"))
   return "Chars: " . l:count . " / 500"
endfunction

set statusline=%f\ %=%{CharCount()}

set laststatus=2