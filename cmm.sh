#!/bin/bash

show_help(){
   echo "Showing help!"
}

# Directory structure: ./Journal/Year/Month/Journal entries sorted by date then time
save_file(){
   YEAR="$(date '+%Y')"
   MONTH="$(date '+%B')"
   DATE="$(date '+%F')"
   TIME="$(date '+%R')"

   DIR="./Journal/$YEAR/$MONTH"
   mkdir -p "$DIR"

   local USER_CONTENT=$1
   echo "$USER_CONTENT" > "./Journal/$YEAR/$MONTH/$DATE-$TIME.md"
}

write_entry(){
   local tmpfile
   local vimrc
   tmpfile="$(mktemp)"
   vim -u ./vimrc "$tmpfile"
   USER_INPUT="$(cat "$tmpfile")"

   if (( ${#USER_INPUT} > 500 )); then
      echo "Rejected: input exceeds 500 characters"
      exit 1
   fi

   if (( ${#USER_INPUT} < 2 )); then
      echo "File discarded"
      exit 1
   fi
   # echo "File contents:"
   # echo "$(cat "$tmpfile")"

   rm -f "$tmpfile"

   save_file "$USER_INPUT"
}

post_entry(){
   # TODO: Image upload feature
   # Maybe handled by sending images to an image storage site, then linking the image into the entry/post
   set -e
   set -a
   source .env
   set +a

   # TODO: Allow multiple API's compatable and configurable through .config file
   # Default Mastodon for now
   # curl -s -X POST "$INSTANCE/api/v1/statuses" \
   #    -H "Authorization: Bearer $API_KEY" \
   #    -d "status=$USER_INPUT"

   # echo "Posted entry:"
   # echo "$USER_INPUT"
}

get_latest(){
   LATEST_FILE="$(find ./Journal -type f -name "*.md" | sort | tail -n 1)"
   # echo "$LATEST_FILE"
   # echo "$(cat $LATEST_FILE)"
   echo "$LATEST_FILE"
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
      case "$2" in 
         latest | l)
            LATEST_FILE=$(get_latest)
            rm "$LATEST_FILE"
         ;;
         *)
            # TODO: Filter garbage out (only allow format specified in config)
            # Then allow deletion of certain saved file
         ;;
      esac
   ;;
   
   -dp | --delete-post)
      case "$2" in
         latest | l)
         ;;
         *)
         ;; 
      esac
   ;;

   -e | --edit)
      case "$2" in
         latest | l)
            LATEST_FILE=$(get_latest)
            vim -u ./vimrc "$LATEST_FILE"
         ;;
         *)
            # TODO: Filter garbage out (only allow format specified in config)
            # Then allow deletion of certain saved file
         ;;
      esac
   ;;

   -v | --view)
      case "$2" in
         latest | l)
            LATEST_FILE=$(get_latest)
            cat "$LATEST_FILE"
         ;;
         *)

         ;;
      esac
   ;;

   -vp | --view-post)
      case "$2" in
         latest | l)
            LATEST_FILE=$(get_latest)
         ;;
         *)

         ;;
      esac
   ;;

   -h | --help) show_help ;;
   *)           show_help ;;
esac