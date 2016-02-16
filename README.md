# film-json

**PERSONAL REPO**
This relates to data taken using the OMDB api.
This is then inserted into an sqlite database and then queries using some simple command line scripts.


## TODO

Add descriptions of other programs.
 

## Inserting New Movies Into database

 1. rename files.list or backup
 2. put IMDB ID's in files.list
 3. run `./retrieveJson.rb`
    This will create some new .json file/s, but not touch existing ones.
 4. run `./convert.rb` (this also takes from files.list
    This will insert data into table imdb in imdb.sqlite

### Finding IMDBID:

1. Use `titlesearch.sh --search "partial or full name"`,
This returns 1 or more matches with year. 
2. Place the required tt code in files.list and run `./retrieveJson.rb` and then `convert.rb`

## Getting imdb id's from wikipedia pages.

    grep -o -h 'www.imdb.com/title/tt[0-9]*' *.html | cut -f3 -d'/' > files.list

if it is a imdb page then it will be:

    grep -o -h 'href="/title/tt[0-9]*' *.html | cut -f3 -d'/' > files.list

If you don't put href=" then there will be many more titles on the side, possibly that will come that we may not want.


Sometimes the name of the file does not match the imdbID since the page was forwarded. Happened only once.

     grep -o 'imdbID":"tt[0-9]*"' tt*.json | tr -d '"' | sed 's/\./:/' > temp.t
     awk -F: '{ if ($1 != $4) { print  $1; }}' temp.t

## Program Summary

`check_imdb.sh` - Checks database for given title (and year). Returns 0 or 1 (found/not found)

`convert.rb` - imports into sqlite

`cu.sh` - calls check_imdb.sh and if not found then titlesearch.sh

`get_title_for_imdbid.sh` - given ttcode print title

`getimdbid.sh` - print imdbid for a given title.

`imdb.sh` - lists movies matching given criteria such as director or actor or title

`retrieveJson.rb` - fetches movie data from OMDB for files in files.list

`titlesearch.sh` - searches for title using OMDB if not in local database

`updatedb.rb` - updates table from given json files (if json has changed)
