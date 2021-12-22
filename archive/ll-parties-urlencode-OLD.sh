DL_PARALLEL=15  # parallel downloads (rejected if too many: Error 429)

DT_VAR="&lllimit=500"  # max number of langlinks per article (500 max)

ROOT=$PWD"/langlinks/parties/"  # USE WIKITAGS-PROJECT STRUCTURE HERE!

PF_DIR="01-partyfacts/"
PF_FILE="pf-core.csv"
PF_URL="https://partyfacts.herokuapp.com/download/core-parties-csv/"

DL_DIR="02-wp-dl/"
TITLES_FILE="titles.txt"
CONFIG_FILE="config.txt"

API="https://en.wikipedia.org/w/api.php"
DT_FIX="?action=query&format=json&prop=langlinks&llprop=url"
DT_PREFIX="&titles="



## Get partyfacts data ----

[[ -f $ROOT$PF_DIR$PF_FILE ]] || curl $PF_URL -o $ROOT$PF_DIR$PF_FILE


## Keep partyfacts IDs and make list of page titles from urls ----

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
' $ROOT$PF_DIR$PF_FILE | awk NF > $ROOT$TITLES_FILE


## Make sure all URLs that need encoding are encoded ----

awk '{ print $2 }' $ROOT$TITLES_FILE  \
  | jq -R -r @uri  \
  | awk '{ gsub("%25","%"); print }'  \
  | paste $ROOT$TITLES_FILE -  \
  | awk '{ print $1, $3 }' > tmp && mv tmp $ROOT$TITLES_FILE
  

## Get language links as .json ----

awk -v dl_dir=$ROOT$DL_DIR -v url_prefix=$API$DT_FIX$DT_VAR$DT_PREFIX '
{ 
  print "-o " dl_dir $1 ".json" 
  print "url = " "\"" url_prefix $2 "\""
}
' $ROOT$TITLES_FILE > $ROOT$CONFIG_FILE

curl -f -Z --parallel-max $DL_PARALLEL -K $ROOT$CONFIG_FILE

rm $ROOT$CONFIG_FILE