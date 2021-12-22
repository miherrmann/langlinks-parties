FILES=$(ls $ROOT$DL_DIR)
PFIDS=${FILES//.json/}

for pfid in $PFIDS
do
  awk -v pfid=$pfid '
  { 
    gsub("^{", "{\"partyfacts_id\":"pfid",")
    print
  }
  ' $ROOT$DL_DIR$pfid".json" > $ROOT$MERGED_DIR$pfid".json"
done
