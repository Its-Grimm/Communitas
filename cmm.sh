#!/bin/bash

show_help(){
   echo "Showing help!"
}

# Directory structure: ./Journal/Year/Month/Journal entries sorted by date then time
save_file(){
   YEAR="$(date '+%Y')"
   MONTH="$(date '+%B')"
   DATE="$(date '+%F')"
   TIME="$(date '+%R' | sed -r 's/://g')" 

   DIR="./Journal/$YEAR/$MONTH"
   mkdir -p "$DIR"

   local USER_CONTENT=$1
   echo "$USER_CONTENT" > "./Journal/$YEAR/$MONTH/$DATE-$TIME.md"
}

write_entry(){
   local tmpfile
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

   rm -f "$tmpfile"
   save_file "$USER_INPUT"
}

post_entry(){
   # TODO: Image upload feature
   # Maybe handled by sending images to an image storage site, then linking the image into the entry/post
   local POST_CONTENT
   if [[ -n "$1" ]]; then
      POST_CONTENT="$1"
   fi

   set -e
   set -a
   source .env
   set +a

   # TODO: Allow multiple API's compatable and configurable through .config file
   # Default Mastodon for now, since that's what I use
   mastodon_post "$POST_CONTENT"
}

get_latest(){
   LATEST_FILE="$(find ./Journal -type f -name "*.md" | sort | tail -n 1)"
   # echo "$LATEST_FILE"
   # echo "$(cat $LATEST_FILE)"
   echo "$LATEST_FILE"
}

get_latest_post(){
   set -e
   set -a
   source .env
   set +a

   INSTANCE="https://mastodon.social"
   LATEST_POST="$(curl -s -X GET "$INSTANCE/api/v1/accounts/$ACCT_ID/statuses?limit=1" \
                   -H "Authorization: Bearer $API_KEY")"

   echo "$LATEST_POST" | jq -r '.[0].content' \
      | sed -E " s#</p>#\n\n#g; s#<br */?>#\n#g; s#<[^>]+>##g; s/&nbsp;/ /g; s/&amp;/\&/g; s/&#39;/'/g; "
}

mastodon_post(){
   local POST_CONTENTS=$1
   INSTANCE="https://mastodon.social"
   # curl -sS -X POST "$INSTANCE/api/v1/statuses" \
   #    -H "Authorization: Bearer $API_KEY" \
   #    --data-urlencode "status=$POST_CONTENTS"

   echo "POSTED!!!!"
}

case "$1" in 
   -w | --write)
      write_entry
   ;;

   -p | --post)
      LATEST_FILE=$(get_latest)
      post_entry "$(cat "$LATEST_FILE")"
   ;;

   -wp | --write-post)
      write_entry
      LATEST_FILE=$(get_latest)
      post_entry "$(cat "$LATEST_FILE")"
   ;;

   -d | --delete)
      case "$2" in 
         l | latest)
            LATEST_FILE=$(get_latest)
            if (( ! ${#LATEST_FILE} == 0 )); then
               rm "$LATEST_FILE"
            else 
               echo "There are no entries"
            fi 
         ;;
         *)
            # TODO: Filter garbage out (only allow format specified in config)
            # Then allow deletion of certain saved file
         ;;
      esac
   ;;
   
   -dp | --delete-post)
      case "$2" in
         l | latest)
            LATEST_FILE=$(get_latest_post)
            if (( ! ${#LATEST_FILE} == 0 )); then
               echo ""
            else 
               echo "There are no entries"
            fi
         ;;
         *)
         ;; 
      esac
   ;;

   -e | --edit)
      case "$2" in
         l | latest)
            LATEST_FILE=$(get_latest)
            if (( ! ${#LATEST_FILE} == 0 )); then
               vim -u ./vimrc "$LATEST_FILE"
            else 
               echo "There are no entries"
            fi
         ;;
         *)
            # TODO: Filter garbage out (only allow format specified in config)
            # Then allow deletion of certain saved file
         ;;
      esac
   ;;

   -ep | --edit-post)
      case "$2" in
         l | latest)
            LATEST_FILE=$(get_latest_post)
            if (( ! ${#LATEST_FILE} == 0 )); then
               vim -u ./vimrc "$LATEST_FILE"
            else 
               echo "There are no entries"
            fi
         ;;
         *)
            # TODO: Filter garbage out (only allow format specified in config)
            # Then allow deletion of certain saved file
         ;;
      esac
   ;;

   -v | --view)
      case "$2" in
         l | latest)
            LATEST_FILE=$(get_latest)
            if (( ! ${#LATEST_FILE} == 0 )); then
               cat "$LATEST_FILE"
            else 
               echo "There are no entries"
            fi
         ;;
         *)

         ;;
      esac
   ;;

   -vp | --view-post)
      case "$2" in
         l | latest)
            LATEST_POST=$(get_latest_post)
            if (( ! ${#LATEST_POST} == 0 )); then
               echo "$LATEST_POST"
            else 
               echo "There are no entries"
            fi
         ;;
         r | random)
         ;;
         *)

         ;;
      esac
   ;;

   -h | --help) show_help ;;
   *)           show_help ;;
esac