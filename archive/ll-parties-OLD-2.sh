WD=$PWD

# Project parameters ----

ROOT="langlinks/parties/"  # USE WIKITAGS-PROJECT STRUCTURE HERE!
DL_DIR="wp-dl/"
TITLES_FILE="titles.txt"


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

awk 'NR == 724 { print }' $ROOT$TITLES_FILE


## Get language links as .json ----

URL=$(awk '{ 
  gsub("^","\\&titles=")
  gsub("^","\\&llprop=url\\&lllimit=500")
  gsub("^","?action=query\\&format=json\\&prop=langlinks")
  gsub("^","https://en.wikipedia.org/w/api.php")
  print
}' ORS=' ' $ROOT$TITLES_FILE)

cd $ROOT$DL_DIR && curl -Z --parallel-max 500 --remote-name-all $URL && cd $WD
