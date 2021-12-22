# Wikipedia language links

Get all language links (i.e. article URL in different language editions of Wikipedia) for political parties that have an article in the English Wikipedia. 
URLs for English Wikipedia articles are obtained from [Party Facts](https://partyfacts.herokuapp.com)


## How to use

[run-ll-parties.sh](run-ll-parties.sh) 

+ assumes project directory: __/$HOME/langlinks-parties/__
+ downloads Party Facts data only if no file: __01-partyfacts/pf-core.csv__
+ downloads langlinks only if no file: __02-wp-dl/ll-parties-raw-\<current date\>.zip__


## Folders

+ __01-partyfacts__ -- Party Facts data
+ __02-wp-dl__ -- downloaded json files
+ __03-processed-data__ -- json files with Party Facts IDs added
+ __04-langlinks-dataset__ -- final dataset (csv)
