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

awk -F ',' '
{ 
  for (i = 1; i <= NF; i++) {
    if ($i == "wikipedia") { wp = i }
  }
  if (NR > 1) { 
    gsub("htt.*://.*wikipedia.org/wiki/", "") $wp
    print $wp 
  }
}
' $ROOT$PF_DIR$PF_FILE | awk '/./' > $ROOT$TITLES_FILE


## Get language links as .json ----

awk -v dl_dir=$ROOT$DL_DIR '
{ 
  gsub("$",".json\"")
  gsub("^","-o "dl_dir"\"")
  print
}
' $ROOT$TITLES_FILE > $ROOT$CONFIG

awk '
{ 
  gsub("$","\"")
  gsub("^","\\&titles=")
  gsub("^","\\&prop=langlinks\\&llprop=url\\&lllimit=500")
  gsub("^","?action=query\\&format=json")
  gsub("^","url = \"https://en.wikipedia.org/w/api.php")
  print
}
' $ROOT$TITLES_FILE >> $ROOT$CONFIG

curl -Z --parallel-max 10 --create-dirs -K $ROOT$CONFIG