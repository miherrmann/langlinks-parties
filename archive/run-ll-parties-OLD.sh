N_PARLL=15   # parallel downloads (too many: Error 429)
N_LINKS=500  # max number of langlinks per article (max: 500)

PROJECT_DIR="langlinks/parties/"
PF_DIR="01-partyfacts/"
DL_DIR="02-wp-dl/"
MERGED_DIR="03-merged-dl-pfids/"
OUT_DIR="04-langlinks-dataset/"

PF_FILE="pf-core.csv"
TITLES_FILE="titles.txt"  # necessary only if urls are not encoded
OUT_CSV="langlinks.csv"


## Parameters ----

ROOT=$PWD/$PROJECT_DIR  # USE WIKITAGS-PROJECT STRUCTURE HERE!
PF_D=$ROOT$PF_DIR
DL_D=$ROOT$DL_DIR
MERG_D=$ROOT$MERGED_DIR
PF_F=$ROOT$PF_DIR$PF_FILE
TITL_F=$ROOT$TITLES_FILE
OUT_F=$ROOT$OUT_DIR$OUT_CSV

PF_URL="https://partyfacts.herokuapp.com/download/core-parties-csv/"
WP_API="https://en.wikipedia.org/w/api.php"
WP_DAT="?action=query&format=json&prop=langlinks&llprop=url"
WP_DAT_VAR="&lllimit="$N_LINKS
WP_DAT_TITLES_PRE="&titles="
WP_URL_PREFX=$WP_API$WP_DAT$WP_DAT_VAR$WP_DAT_TITLES_PRE


## Get partyfacts data ----

[[ -f $PF_F ]] || curl $PF_URL -o $PF_F


## Make data set with partyfacts IDs and page titles ----

awk -F "," '
{
  for (i = 1; i <= NF; i++) {
    if ($i == "partyfacts_id") { pf = i }
    if ($i == "wikipedia") { wp = i }
  }
  if (NR > 1) {
    gsub("htt.*://.*wikipedia.org/wiki/", "") $wp
    if ($wp == "") { $pf = "" }
    print $pf, $wp
  }
}
' $PF_F | awk NF > $TITL_F


## Ensure all titles that need URL encoding are encoded ----

awk '{ print $2 }' $TITL_F |
  jq -R -r @uri |
  awk '{ gsub("%25","%"); print }' |
  paste $TITL_F - |
  awk '{ print $1, $3 }' > tmp && mv tmp $TITL_F


## Get language links as .json files ----

[[ -d $DL_D ]] || awk -v dir=$DL_D -v prefix=$WP_URL_PREFX '
{
  print "-o " dir $1 ".json"
  print "url = " "\"" prefix $2 "\""
}
' $TITL_F |
  curl -f -Z --parallel-max $N_PARLL --create-dirs -K - && rm $TITL_F


## Add Party Facts ID as first key in .json files ----

rm $MERG_D* && cp $DL_D* $MERG_D
ls $MERG_D |
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
