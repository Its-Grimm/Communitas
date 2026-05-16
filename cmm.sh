#!/bin/bash

show_help(){
   echo "Showing help!"
}

write_entry(){
   local tmpfile
   local vimrc
   tmpfile="$(mktemp)"
   vimrc="$(mktemp)"

   cat > "$vimrc" << EOF
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
EOF

   vim -u "$vimrc" "$tmpfile"
   USER_INPUT="$(cat "$tmpfile")"

   if (( ${#USER_INPUT} > 500 )); then
      echo "Rejected: input exceeds 500 characters"
      exit 1
   fi

   # echo "File contents:"
   # echo "$(cat "$tmpfile")"

   rm -f "$tmpfile"
}

post_entry(){
   # TODO: Image upload features
   set -e
   set -a
   source .env
   set +a

   # TODO: Allow multiple API's compatable and configurable through .config file
   # Mastodon for now
   # curl -s -X POST "$INSTANCE/api/v1/statuses" \
   #    -H "Authorization: Bearer $API_KEY" \
   #    -d "status=$USER_INPUT"

   echo "Posted entry:"
   echo "$USER_INPUT"
}

case "$1" in 
   -w | --write)
      write_entry
      ;;

   -p | --post)
      post_entry
      ;;

   -wp | --write-post)
      write_entry
      post_entry
      ;;

   -d | --delete)

      ;;

   -h | --help) 
      show_help
      ;;
   *)
      show_help
      ;;
esac
