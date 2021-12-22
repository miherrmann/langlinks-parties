PROJECT_DIR="langlinks/parties/"
DL_DIR="02-wp-dl/"
MERGED_DIR="03-merged-dl-pfids/"
OUT_DIR="04-langlinks-dataset/"

OUT_CSV="langlinks.csv"


## Parameters ----

ROOT=$PWD/$PROJECT_DIR  # USE WIKITAGS-PROJECT STRUCTURE HERE!
DL_D=$ROOT$DL_DIR
MERG_D=$ROOT$MERGED_DIR

OUT_F=$ROOT$OUT_DIR$OUT_CSV


## Add Party Facts ID as first key in .json files ----

rm $MERG_D* && cp $DL_D* $MERG_D
ls $MERG_D  | 
  sed -n 's/\.json//p' | 
  xargs -P 5000 -i sed -i 's/{/{\"partyfacts_id\":'{}',/1' $MERG_D{}.json


## Make .csv ----

jq -s -r '
  ["partyfacts_id", "from", "to", "title", "language", "url"] , 
  (
    .[] 
    | [.partyfacts_id] + 
    (
      .query 
      | (.normalized // [null] | .[] | [.from, .to]) +
      (.pages[] | [.title] + (.langlinks // [null] | .[] | [.lang, .url]))
    )
  )
  | @csv
' $MERG_D* > $OUT_F
