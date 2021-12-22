ROOT=$PWD"/langlinks/parties/"  # USE WIKITAGS-PROJECT STRUCTURE HERE!
DL_DIR="wp-dl/"
LINKS_DIR="links-json/"
TITLES_FILE="titles.txt"
LINKS_FILE="langlinks.json"
PFID="partyfacts_id.txt"


# Join downloaded json files ----

cat $(ls $ROOT$DL_DIR*) > $ROOT$LINKS_DIR$LINKS_FILE

cat $(ls $ROOT$DL_DIR* | head -n 2) > $ROOT$LINKS_DIR$"test.json"

cat $ROOT$DL_DIR"5344.json" $ROOT$DL_DIR"1.json" > $ROOT$LINKS_DIR$"test.json"


# Get partyfacts ids from json filenames ---

ls -f $ROOT$DL_DIR | awk 'gsub("\.json","")' > $ROOT$PFID

# or pure Bash
str=$(dir $ROOT$DL_DIR)
echo ${str//.json/""} > test


# Append partyfacts ids to json links file ----

jq -s '{ partyfacts_id:[.] }' $ROOT$PFID \
  | cat $ROOT$LINKS_DIR$LINKS_FILE - > test

jq '.query' test


## Make .csv ----

# That's it!!! ----

jq  -r '
  ["from", "to", "title", "language", "url"] , 
  (.query.normalized[] | [.from, .to]) +
  (.query.pages[] | [.title] + (.langlinks[] | [.lang, .url]))
  | @csv
' $ROOT$LINKS_DIR$LINKS_FILE > $ROOT$LINKS_DIR"langlinks.csv"

# Try to improve ----

# Headers not to be repeated ----

jq -s -r '
  ["from", "to", "title", "language", "url"] , (
    .[].query | 
      (.normalized | .[] | [.from, .to]) + 
      (.pages | .[] | [.title] + (.langlinks // empty | .[] | [.lang, .url]))
  )
' $ROOT$LINKS_DIR"test.json" 

jq -s -r '
  ["from", "to", "title", "language", "url"] , 
  (
    .[].query | 
      (.normalized // [null] | .[] | [.from, .to]) + 
      (.pages | .[] | [.title] + (.langlinks // [null] | .[] | [.lang, .url]))
  ) 
  | @csv
' $ROOT$LINKS_DIR$LINKS_FILE > $ROOT$LINKS_DIR"langlinks1.csv"

jq -s -r '
  ["from", "to", "title", "language", "url"] , 
  (
    .[].query | 
      (.normalized // empty | .[] | [.from, .to]) + 
      (.pages | .[] | [.title] + (.langlinks // empty | .[] | [.lang, .url]))
  ) 
  | @csv
' $ROOT$LINKS_DIR$LINKS_FILE > $ROOT$LINKS_DIR"langlinks2.csv"



# Include partyfacts IDs as first key: i.e., replace .[] with .pf[] ----

jq -s '.[] | .query' $ROOT$LINKS_DIR"test.json" 

echo '{}' | jq -s '.'


jq -s '
  .[] | [..|.langlinks? == null] | all 
' $ROOT$LINKS_DIR"test.json" 

jq -s '
  [.[] | [..|.langlinks?] | any] 
' $ROOT$LINKS_DIR"test.json" 

jq -s '[(..|.langlinks?) == null] | all' $ROOT$LINKS_DIR"test.json" 
jq  -r 'all([..|.langlinks?]; null)' $ROOT$DL_DIR"5344.json" 
jq  -r '[..|.langlinks?] | null' $ROOT$DL_DIR"5344.json" 


