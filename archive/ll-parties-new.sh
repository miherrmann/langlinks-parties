WD=$PWD

# Project parameters ----

ROOT=$PWD"/langlinks/parties/"  # USE WIKITAGS-PROJECT STRUCTURE HERE!
DL_DIR="wp-dl/"
TITLES_FILE="titles.txt"
CONFIG="config.txt"


## Get partyfacts data ----

PF_URL="https://partyfacts.herokuapp.com/download/core-parties-csv/"
PF_DIR="partyfacts/"
PF_FILE="pf-core.csv"

[[ -f $ROOT$PF_DIR$PF_FILE ]] || curl $PF_URL -o $ROOT$PF_DIR$PF_FILE


## Make list of page titles as .txt ----

awk -F ',' 'NR > 1 {
  gsub("htt.*://.*wikipedia.org/wiki/","") $13
  print $13
}' $ROOT$PF_DIR$PF_FILE | awk '/./' > $ROOT$TITLES_FILE


## Get language links as .json ----

awk '{ 
  gsub("$","\"")
  gsub("^","\\&titles=")
  gsub("^","\\&llprop=url\\&lllimit=500")
  gsub("^","?action=query\\&format=json\\&prop=langlinks")
  gsub("^","url = \"https://en.wikipedia.org/w/api.php")
  print
}' $ROOT$TITLES_FILE > $ROOT$CONFIG

cd $ROOT$DL_DIR
curl -f -Z --parallel-max 10 --remote-name-all -K $ROOT$CONFIG
cd $WD

awk 'NR == 4847 { print }' $ROOT$CONFIG

cd $HOME

curl "https://en.wikipedia.org/w/api.php?action=query&format=json&prop=langlinks&llprop=url&lllimit=500&titles=Zehut"
