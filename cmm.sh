#!/bin/bash

set -e
set -a
source .env
set +a

show_help(){
cat <<'EOF'
cmm.sh — Journal + Mastodon CLI tool

USAGE:
  cmm.sh [OPTION] [ARG]

────────────────────────────────────────
JOURNAL COMMANDS
────────────────────────────────────────

  -w,  --write
      Create a new journal entry (opens editor)

  -p,  --post
      Post latest journal entry to Mastodon

  -wp, --write-post
      Write entry and immediately post it

────────────────────────────────────────
VIEWING ENTRIES
────────────────────────────────────────

  -e,  --edit l|latest
      Edit latest local journal entry in editor

  -v,  --view l|latest
      View latest journal entry in editor (vim)

  -v,  --view l|latest
      Print latest journal entry to stdout

  -vp, --view-post l
      View latest Mastodon post (formatted)

  -vp, --view-post r
      Random post (not implemented)

────────────────────────────────────────
DELETION
────────────────────────────────────────

  -d,  --delete l|latest
      Delete latest local journal entry

  -dp, --delete-post l
      Delete latest Mastodon post AND (optionally) local copy

────────────────────────────────────────
EDITING POSTS
────────────────────────────────────────

  -ep, --edit-post l
      Edit latest Mastodon post (opens editor, then updates remote)

────────────────────────────────────────
CONFIGURATION (~/.config or .config)
────────────────────────────────────────

  default_location=./Journal
      Base directory for all journal files

  date_style=yyyy-mm-d
      Controls folder/file naming format:
        d/mm/yyyy   = 3/06/2024
        dd/mm/yyyy  = 03/06/2024
        d/m/yyyy    = 3/6/2024
        d/m/yy      = 3/6/24
        yyyy-mm-d   = 2024-06-3

  time_style=hh:mm
      Time format used in filenames:
        hh:mm-ampm  = 04:15 pm
        h:mm-ampm   = 4:15 pm
        h:mm-AMPM   = 4:15 PM
        h:mm        = 16:15

  platforms="Mastodon"
      Active posting targets (future multi-platform support)

  editor="vim"
      Default editor used for writing/editing entries

  effect_local_when_post=true
      If true:
        local journal entries are modified/deleted when using -*p commands
      If false:
        local and remote posts are decoupled

────────────────────────────────────────
REQUIREMENTS
────────────────────────────────────────

  - .env file must define:
      API_KEY
      ACCT_ID

  - Mastodon instance:
      https://mastodon.social

  - External tools:
      jq, curl, vim (or configured editor)

────────────────────────────────────────
EXAMPLES
────────────────────────────────────────

  cmm.sh -w
  cmm.sh -wp
  cmm.sh -vp l
  cmm.sh -dp l
  cmm.sh -ep l

EOF
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

edit_post(){
   local tmpfile
   tmpfile="$(mktemp)"
   LATEST_POST=$(./cmm.sh -vp l)
   printf '%s' "$LATEST_POST" > "$tmpfile"
   
   vim -u ./vimrc "$tmpfile"
   USER_INPUT="$(cat "$tmpfile")"

   ID=$(get_latest_post | jq -r '.[0].id') || { 
                                                echo "ID could not be extracted" 
                                                exit 1 
                                              }

   curl -o /dev/null -X PUT "https://mastodon.social/api/v1/statuses/$ID" \
      -H "Authorization: Bearer $API_KEY" \
      --data-urlencode "status=$USER_INPUT"

   # Also edits local file, behaviour configurable in .config
   LATEST_FILE=$(get_latest)
   if [[ -n "$LATEST_FILE" ]]; then
      printf '%s' "$USER_INPUT" > "$LATEST_FILE"
   else 
      echo "There are no entries"
   fi

   rm -f "$tmpfile"
}

post_entry(){
   # TODO: Image upload feature
   # Maybe handled by sending images to an image storage site, then linking the image into the entry/post
   local POST_CONTENT
   if [[ -n "$1" ]]; then
      POST_CONTENT="$1"
   fi

   # TODO: Allow multiple API's compatable and configurable through .config file
   # Default Mastodon for now, since that's what I use
   mastodon_post "$POST_CONTENT"
}

get_latest(){
   LATEST_FILE="$(find ./Journal -type f -name "*.md" | sort | tail -n 1)"
   echo "$LATEST_FILE"
}

get_latest_post(){
   INSTANCE="https://mastodon.social"
   LATEST_POST="$(curl -s -X GET "$INSTANCE/api/v1/accounts/$ACCT_ID/statuses?limit=1" \
                   -H "Authorization: Bearer $API_KEY")"
   echo "$LATEST_POST"
}

mastodon_post(){
   local POST_CONTENTS=$1
   INSTANCE="https://mastodon.social"
   curl -s -o /dev/null -X POST "$INSTANCE/api/v1/statuses" \
      -H "Authorization: Bearer $API_KEY" \
      --data-urlencode "status=$POST_CONTENTS"

   echo "File posted!"
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
            if [[ -n "$LATEST_FILE" ]]; then
               rm -- "$LATEST_FILE"
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
            ID=$(get_latest_post | jq -r '.[0].id') || exit 1
            INSTANCE="https://mastodon.social"
            curl -s -o /dev/null -X DELETE "$INSTANCE/api/v1/statuses/$ID" \
               -H "Authorization: Bearer $API_KEY"

            # Deletes local copy as well (behaviour configurable in .config file)
            LATEST_FILE=$(get_latest)
            if [[ -n "$LATEST_FILE" ]]; then
               rm -- "$LATEST_FILE"
            else 
               echo "There are no entries"
            fi 

            echo "File deleted!"
         ;;
         *)
         ;; 
      esac
   ;;

   -e | --edit)
      case "$2" in
         l | latest)
            LATEST_FILE=$(get_latest)
            if [[ -n "$LATEST_FILE" ]]; then
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
            edit_post
            echo "File edited!"
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
            if [[ -n "$LATEST_FILE" ]]; then
               cat "$LATEST_FILE"
            else 
               echo "There are no entries"
            fi
         ;;
         *)
            if [[ -n "$2" ]]; then
               # TODO: View entry at specified date
               echo ""
            else 
               echo "No filter specified, defaulting to latest"
               LATEST_FILE=$(get_latest)
               if [[ -n "$LATEST_FILE" ]]; then
                  cat "$LATEST_FILE"
               else 
                  echo "There are no entries"
               fi
               fi 

         ;;
      esac
   ;;

   -vp | --view-post)
      case "$2" in
         l | latest)
            LATEST_POST=$(get_latest_post \
               | jq -r '.[0].content' \
               | sed -E " s#</p>#\n\n#g; s#<br */?>#\n#g; s#<[^>]+>##g; s/&nbsp;/ /g; s/&amp;/\&/g; s/&#39;/'/g; ") \
               || { 
                     echo "There are no entries" 
                     exit 1 
                  }
            echo "$LATEST_POST"
         ;;
         r | random)
            RANDOM_POST=$(get_random_post)
         ;;
         *)

         ;;
      esac
   ;;

   -h | --help) show_help ;;
   *)           show_help ;;
esac