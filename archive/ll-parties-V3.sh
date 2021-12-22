DL_PARALLEL=10  # parallel downloads (too high: reject w Error: 422)

ROOT=$PWD"/langlinks/parties/"  # USE WIKITAGS-PROJECT STRUCTURE HERE!

DL_DIR="wp-dl/"
TITLES_FILE="titles.txt"
CONFIG_FILE="config.txt"

API="https://en.wikipedia.org/w/api.php"
DT_FIX="?action=query&format=json&prop=langlinks&llprop=url"
DT_VAR="&lllimit=500"
DT_TITLES="&titles="

PF_URL="https://partyfacts.herokuapp.com/download/core-parties-csv/"
PF_DIR="partyfacts/"
PF_FILE="pf-core.csv"


## Get partyfacts data ----

[[ -f $ROOT$PF_DIR$PF_FILE ]] || curl $PF_URL -o $ROOT$PF_DIR$PF_FILE


## Keep partyfacts IDs and make list of page titles from urls ----

awk -F ',' '
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


## Get language links as .json ----

awk -v dl_dir=$ROOT$DL_DIR '
{ 
  print "-o " dl_dir $1 ".json"
}
' $ROOT$TITLES_FILE > $ROOT$CONFIG_FILE

awk -v url_prefix=$API$DT_FIX$DT_VAR$DT_TITLES '
{ 
  print "url = " "\"" url_prefix $2 "\""
}
' $ROOT$TITLES_FILE >> $ROOT$CONFIG_FILE

curl -Z --parallel-max $DL_PARALLEL --create-dirs -K $ROOT$CONFIG_FILE