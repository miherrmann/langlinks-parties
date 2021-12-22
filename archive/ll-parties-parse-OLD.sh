ROOT=$PWD"/langlinks/parties/"  # USE WIKITAGS-PROJECT STRUCTURE HERE!
DL_DIR="wp-dl/"
LINKS_DIR="links-json"
TITLES_FILE="titles.txt"
LINKS_FILE="langlinks.json"


cat $(ls $ROOT$DL_DIR*) > $ROOT$LINKS_DIR$LINKS_FILE

jq -r '
  [ .query.pages[] ] 
  | ["title", "lang", "url"] , 
  (.[] | [.title] + (.langlinks[] | [.lang, .url])) 
  | @csv
' $ROOT$LINKS_DIR$LINKS_FILE > $ROOT$LINKS_DIR"langlinks.csv"


jq -r '
  [ .query.pages[] ] 
  | ["title", "lang", "url"] , 
  (.[] | [.title] + (.langlinks[] | [.lang, .url])) 
  | @csv
' $ROOT$DL_DIR"982.json"

  
jq -r '[ .query.pages[] ]' $ROOT$LINKS_DIR$LINKS_FILE \
  | jq '
  ["title", "lang", "url"] , 
  (.[] | [.title] + (.langlinks[] | [.lang, .url])) | @csv'