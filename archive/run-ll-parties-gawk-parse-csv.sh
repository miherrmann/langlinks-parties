N_PARLL=10   # parallel downloads (too many: Error 429)
N_LINKS=500  # max number of langlinks per article (max: 500)

PROJECT_DIR="langlinks/parties"
PF_DIR="01-partyfacts"
DL_DIR="02-wp-dl"
MERGED_DIR="03-merged-dl-pfids"
OUT_DIR="04-langlinks-dataset"

PF_FILE="pf-core.csv"
TITLES_FILE="titles.txt"  # necessary only if URLs are not encoded
OUT_CSV="langlinks.csv"

PF_URL="https://partyfacts.herokuapp.com/download/core-parties-csv/"
WP_API="https://en.wikipedia.org/w/api.php"
API_DAT="?action=query&format=json&prop=langlinks&llprop=url&lllimit="
API_DAT_LAST="&titles="


## Paths and destinations ----

ROOT=$HOME/$PROJECT_DIR  # USE WIKITAGS-PROJECT STRUCTURE HERE!
PF_D=$ROOT/$PF_DIR
DL_D=$ROOT/$DL_DIR
MERG_D=$ROOT/$MERGED_DIR
PF_F=$ROOT/$PF_DIR/$PF_FILE
TITL_F=$ROOT/$TITLES_FILE
OUT_F=$ROOT/$OUT_DIR/$OUT_CSV
REQ=$WP_API$API_DAT$N_LINKS$API_DAT_LAST


## Get Party Facts data ----

[[ -f $PF_F ]] || curl $PF_URL -o $PF_F


## Extract partyfacts_id and wikipedia ----

gawk -v FPAT='[^,]*|"[^"]*"' '
  NR == 1 {
    for (i = 1; i <= NF; i++) {
      if ($i == "partyfacts_id") pf = i
      if ($i == "wikipedia") wp = i
    };
    n_var = NF
  };
  NR > 1 && NF == n_var && $wp != "" {
    gsub("http.?://.*wikipedia.org/wiki/", "", $wp);
    gsub("^\"|\"$", "", $wp);
    print($pf, $wp)
  }
' $PF_F > $TITL_F


## Data patching: ensure all page titles are URL encoded ----

cut -d ' ' -f 2 $TITL_F |\
  jq -R -r @uri |\
  sed 's/%25/%/g' |\
  paste -d ' ' $TITL_F - |\
  cut -d ' ' -f 1,3 > tmp && mv tmp $TITL_F


## Get language links: json files ----

[[ -d $DL_D ]] || awk -v dl_dir=$DL_D -v req=$REQ '
  { 
    printf("-o %s%s.json\n", dl_dir, $1);
    printf("url = \"%s%s\"\n", req, $2); 
  }
' $TITL_F |\
  curl -f -Z --parallel-max $N_PARLL --create-dirs -K - && rm $TITL_F
  

## Add partyfacts_id as first key in each json ----

cp $DL_D* $MERG_D
ls $MERG_D |\
  sed -n 's/\.json//p' |\
  xargs -P 5000 -i sed -i 's/{/{\"partyfacts_id\":'{}',/1' $MERG_D{}.json


## Make csv ----

jq -s -r '
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
' $MERG_D* > $OUT_F
