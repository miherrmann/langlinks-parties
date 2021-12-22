N_PARLL=10   # parallel downloads (too many: Error 429)
N_LINKS=500  # max number of langlinks per article (max: 500)

PROJ_DIR="langlinks/parties"
API="https://en.wikipedia.org/w/api.php"
API_DAT="?action=query&format=json&prop=langlinks&llprop=url&lllimit="
API_DAT_LAST="&titles="
PF_URL="https://partyfacts.herokuapp.com/download/core-parties-csv/"
PF_DIR="01-partyfacts"
PF_FILE="pf-core.csv"
DL_DIR="02-wp-dl"
DL_FILE="ll-parties-raw"
PROC_DIR="03-processed-data"
OUT_DIR="04-langlinks-dataset"
OUT_FILE="langlinks.csv"
TI_FILE="titles.txt"  # help file necessary only for step 3


## Locations and queries ----

PROJ_DIR=$HOME/$PROJ_DIR  # USE WIKITAGS-PROJECT STRUCTURE HERE!
API_REQ=$API$API_DAT$N_LINKS$API_DAT_LAST
PF_FILE=$PROJ_DIR/$PF_DIR/$PF_FILE
DL_DIR=$PROJ_DIR/$DL_DIR
DL_FILE=$DL_DIR/$DL_FILE-$(date +"%Y-%m-%d").zip
PROC_DIR=$PROJ_DIR/$PROC_DIR
OUT_FILE=$PROJ_DIR/$OUT_DIR/$OUT_FILE
TI_FILE=$PROJ_DIR/$TI_FILE


## 1. Get Party Facts data ----

[[ -f $PF_FILE ]] || curl $PF_URL -o $PF_FILE


## 2. Extract partyfacts_id and wikipedia fields ----

# Assumes partyfacts_id and country codes are in adjacent columns!

PF_ID="[[:upper:]]{3},[[:digit:]]{1,5}|[[:digit:]]{1,5},[[:upper:]]{3}}"
WP=',http.?://.*wikipedia.org/[^,]*|"http.?://.*wikipedia.org/[^"]*'
PAT=$PF_ID"|"$WP

gawk -v FPAT=$PAT '
  $1 != "" && $2 != "" { 
    gsub(",?[[:upper:]]{3},?", "", $1);
    gsub("(,|\")", "", $2);
    gsub("http.?://.*wikipedia.org/wiki/", "", $2);
    print($1, $2)
  }
' $PF_FILE > $TI_FILE


## 3. Data patching: ensure all page titles are URL encoded ----

cut -d ' ' -f 2 $TI_FILE |\
  jq -Rr @uri |\
  sed 's/%25/%/g' |\
  paste -d ' ' $TI_FILE - |\
  cut -d ' ' -f 1,3 > $PROJ_DIR"tmp" && mv $PROJ_DIR"tmp" $TI_FILE


## 4. Get language links: json files ----

[[ -f $DL_FILE ]] || awk -v dl_dir=$DL_DIR -v req=$API_REQ '
  { 
    printf("-o %s/%s.json\n", dl_dir, $1);
    printf("url = \"%s%s\"\n", req, $2)
  }
' $TI_FILE |\
  curl -fZK - --parallel-max $N_PARLL && zip -mjq $DL_FILE $DL_DIR/* && rm $TI_FILE


## 5. Add partyfacts_id as first key in each json ----

unzip -q -d $PROC_DIR $DL_FILE && ls $PROC_DIR |\
  sed -n 's/\.json//p' |\
  xargs -P 5000 -i sed -i 's/{/{\"partyfacts_id\":'{}',/1' $PROC_DIR/{}.json


## 6. Make csv ----

jq -sr '
  ["partyfacts_id", "from", "to", "title", "language", "url"] , 
  (
    .[] | 
      [.partyfacts_id] + 
      (
        .query | 
          (.normalized // [null] | .[] | [.from, .to]) +
          (.pages[] | [.title] + (.langlinks // [null] | .[] | [.lang, .url]))
      )
  ) 
  | @csv
' $PROC_DIR/* > $OUT_FILE
