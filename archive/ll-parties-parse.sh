ROOT=$PWD"/langlinks/parties/"  # USE WIKITAGS-PROJECT STRUCTURE HERE!
DL_DIR="wp-dl/"
LINKS_DIR="links-json/"
TITLES_FILE="titles.txt"
PFID_FILE="partyfacts_id.txt"
LINKS_JSON="langlinks.json"
LINKS_CSV="langlinks.csv"


# Join downloaded json files ----

cat $(ls $ROOT$DL_DIR*) > $ROOT$LINKS_DIR$LINKS_JSON


## Make .csv ----

jq -s -r '
  ["from", "to", "title", "language", "url"] , 
  (
    .[].query | 
      (.normalized // [null] | .[] | [.from, .to]) + 
      (.pages[] | [.title] + (.langlinks // [null] | .[] | [.lang, .url]))
  ) 
  | @csv
' $ROOT$LINKS_DIR$LINKS_FILE > $ROOT$LINKS_DIR$LINKS_CSV
