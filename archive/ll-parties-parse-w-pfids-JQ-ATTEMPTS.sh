ROOT=$PWD"/langlinks/parties/"  # USE WIKITAGS-PROJECT STRUCTURE HERE!
DL_DIR="wp-dl/"
LINKS_DIR="links-json/"
TITLES_FILE="titles.txt"
PFID_FILE="partyfacts_id.txt"
LINKS_JSON="langlinks.json"
LINKS_CSV="langlinks.csv"


# Join downloaded json files ----

cat $(ls $ROOT$DL_DIR*) > $ROOT$LINKS_DIR$LINKS_JSON


## Works!! ----

jq -n '
{
  data: [
    {
      pfid: "one",
      query: {normalized: [{from: 1, to: 3}]}, 
      langlinks: [{link: 3, url: "z"}, {link: 2, url: "x"}]
    },
    {
      pfid: "two",
      query: {normalized: [{from: 1, to: 3}]}, 
      langlinks: [{link: 3, url: "z"}, {link: 2, url: "x"}]
    }
  ],
  pf: 
    {
      one: 123, 
      two: 234
    }
}
' | jq '.pf as $id | .data[] | {pfid: $id[.pfid], query, langlinks}'


## Almost, but produces every combination instead of just two objects ----

jq -n '
{
  data: [
    {
      query: {normalized: [{from: 1, to: 3}]}, 
      langlinks: [{link: 3, url: "z"}, {link: 2, url: "x"}]
    },
    {
      query: {normalized: [{from: 1, to: 3}]}, 
      langlinks: [{link: 3, url: "z"}, {link: 2, url: "x"}]
    }
  ],
  pf: [{"1": 123}, {"2": 234}]
}
' 
| jq '
  foreach (.data | keys) as $idx (.; +1; .data[] += {"pfid": .pf[($idx)[]]})
'



jq -n '
 {
 "realnames": ["Anonymous Coward", "Person McPherson"],
 "names": {first: "one", second: "two"}
 }
 ' | jq 'keys-unsorted as $idx | .[$idx[]]'
 

# This could be it ----

jq -n '
  {k: {pfid: null, b: 2}, d: {pfid: null, b: 2}} * 
  {k: {pfid: 0}, d: {pfid: 3}}
'

jq -n '
  {a: [{pfid: null, b: 12}, {pfid: null, b: 56}]} *
  {a: [{pfid: 0}, {pfid: 3}]}
'
