ROOT="langlinks/parties/"
DL_DIR="wp-dl/"


## Get partyfacts data ----

PF_URL="https://partyfacts.herokuapp.com/download/core-parties-csv/"
PF_DATA="pf-core.csv"

[[ -f $ROOT$PF_DATA ]] || curl $PF_URL -o $ROOT$PF_DATA


## Make list of page titles .txt ----

awk -F ',' 'NR > 1 {
  gsub("htt.*://.*wikipedia.org/wiki/","") $13
  print $13
}' $ROOT$PF_DATA | awk '/./' > $ROOT"titles.txt"


## Get language links .json ----

API="https://en.wikipedia.org/w/api.php"
DATA="?action=query&format=json&prop=langlinks&llprop=url&lllimit=500"
#TITLES=$(awk '{ print }' ORS=',' $ROOT"titles.txt" | awk '{ gsub(",$",""); print }')

TITLES=$(awk 'NR < 10 { print }' ORS=',' $ROOT"titles.txt" | awk '{ gsub(",$",""); print }')

curl $API$DATA"&titles={$TITLES,Alliance_90/The_Greens}" -o $ROOT$DL_DIR"#1.json" -Z --parallel-max 500