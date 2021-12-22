PARTY="Alternative_for_Germany"
PARAM="?action=query&format=json&prop=langlinks&llprop=url&lllimit=500&titles="

curl -O "https://en.wikipedia.org/w/api.php"${PARAM}${PARTY}

JSON_FILE=$(ls | grep $PARAM$PARTY)
jq '
  .query.pages[].langlinks 
  | .[] 
  | select(.lang == "de" or .lang == "fr" or .lang == "es")
  ' $JSON_FILE



## Parallel requests ----

split -l 1000 configfile.txt configfile.part  # split file if too many urls

cat downloads | xargs -P 10 -n 1 curl -O

xargs -P 20 -n 1 curl -O < downloads

P1="Alternative_for_Germany"
P2="Social_Democratic_Party_of_Germany"
API="https://en.wikipedia.org/w/api.php"
DATA="?action=query&format=json&prop=langlinks&llprop=url&lllimit=500&titles="
curl ${API}${DATA}"{$P1,$P2}" -o "wiki-langlinks/#1.json" -Z



## Snippets ----

TITLES=$(awk 'NR < 500' ORS=',' $ROOT"titles.txt" | awk '{ gsub(",$",""); print }')

curl "https://en.wikipedia.org/w/api.php" -d "action=query" -d "format=json" -d "prop=langlinks" -d "llprop=url" -d "lllimit=500" -d -o "wiki-langlinks/test.json"

curl -H "Accept: application/json" "https://en.wikipedia.org/w/api.php?action=query&format=json&prop=langlinks&llprop=url&lllimit=500&titles=Alternative_for_Germany" | jq '.'
curl "https://en.wikipedia.org/w/api.php?action=query&format=json&prop=langlinks&llprop=url&titles=Alternative_for_Germany" | jq '.'

# ----

curl -o afd.json "https://en.wikipedia.org/w/api.php?action=query&format=json&prop=langlinks&llprop=url&lllang=fr&titles=Alternative_for_Germany"
id=$(jq '.query.pages | keys' afd.json | jq '.[]')
jq '.query.pages[].langlinks' afd.json

# ----

PARTY="Alternative_for_Germany"
LANG1='"de"'
LANG2='"fr"'
LANG3='"es"'

PARAM="?action=query&format=json&prop=langlinks&llprop=url&lllimit=500&titles="
API="https://en.wikipedia.org/w/api.php"
JQ_FILTER=".query.pages[].langlinks | .[] | "
JQ_SELECT="select(.lang == ${LANG1} or .lang == ${LANG2} or .lang == ${LANG3})"
JQ_FILTER_SELECT="$JQ_FILTER$JQ_SELECT"

curl -O $API$PARAM$PARTY
JSON_FILE=$(ls | grep $PARAM$PARTY)
jq --arg FILTER_SELECT $JQ_FILTER_SELECT '$FILTER_SELECT' $JSON_FILE
  