#!/usr/bin/env zsh
# ----------------------------------------------------------------------------- #
#         File: imdb.sh
#  Description: lists movies for a given criteria such as director or actor or title
#               using movies.sqlite database
#       Author: rkumar http://github.com/rkumar/
#         Date: 2015-10-26 13:39
#  Last update: 2015-12-24 00:40
#      License: Free
#  Location: 
#  BUGS:        Currently cannot take ' in movie name: e,g, Dead Men Don't Wear Plaid
#  TODO:        This should have options and commands separate. top-rated top-voted starring 
#                etc can be commands. This should be done in ruby, it's a mess.
# ----------------------------------------------------------------------------- #
#
# We need to have short and long (with plot and mode=line) otherwise without plot it can be with tabs
MYVER=0.0.2
SQLITE=$(brew --prefix sqlite)/bin/sqlite3

usage() {
cat <<!
imdb.sh $MYVER  Copyright (C) 2015 rahul kumar
This program lists movies based on certain criteria using imdb.sqlite as source.
The output is meant to be further filtered or transformed using cut or grep or awk.
You may filter based on the following criteria:
  -t | --title   <name of part of movie name>
  -d | --directed_by | -- director  <name of director>
  -s | --starring | --actor <name of actor>
Others:
  Show only title
  --brief
  Display modes (see sqlite3 help)
  --mode line|html|csv|tabs|list
  Debug (show some echo statements)
  --debug

  --stdin <column name> data for column_name will follow on STDIN. column is a valid column
         from imdb table such as director actors imdbId title
         This must be the last option on command line. e,g,
       echo "Ozu" | imdb.sh --stdin director

  --top-voted <n>     Show top voted n titles
  --top-rated <n>     Show top rated n titles

!
}

top_voted ()
{
    num="$1"

cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/imdbdata/ || exit
$SQLITE imdb.sqlite <<!
    
$_MODE
.header $_HEADER
SELECT 
imdbID,
Title,
imdbRating,
imdbVotes
FROM imdb
WHERE imdbVotes != "N/A"
order by imdbVotes desc
 LIMIT ${num};
!
}	# ----------  end of function top_voted  ----------
top_rated ()
{
    num="$1"

cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/imdbdata/ || exit
$SQLITE imdb.sqlite <<!
$_MODE
.header $_HEADER
SELECT 
imdbID,
Title,
imdbRating,
imdbVotes
FROM imdb
where imdbRating != "N/A"
and imdbVotes > 1000
order by imdbrating desc
 LIMIT ${num};
!
}	# ----------  end of function top_rated  ----------


movies_for_year ()
{
    year="$1"
cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/imdbdata/ || exit

$SQLITE imdb.sqlite <<!
$_MODE
.header $_HEADER
SELECT 
imdbID,
Title,
Year,
Director
FROM imdb
where year = $year;
!

}	# ----------  end of function movies_for_year  ----------
setopt EXTENDED_GLOB
OPT=${*:-${OPT}}
PATT=""
RDEBUG=:
FIELD=""
_MODE=".mode line"
_MODE=".mode tabs"
# filter appends the column and search value (FIELD and PATT)
_FILTER=""
_HEADER=" OFF "
_MYOPERATOR=" LIKE "
_MYWC="%"
_COLUMNS="imdbid, title, year, director , actors, runtime, plot "
while [[ $1 = -* ]]; do
case "$1" in
    -h|--help)
        usage
        exit
        ;;
    --brief)
        _COLUMNS=" title "
        shift
        ;;
    --exact)
        _MYOPERATOR=" = "
        # at least be case insensitive
        _MYOPERATOR=" LIKE "
        _MYWC=""
        shift
        ;;
    --debug)
        RDEBUG=echo
        shift
        ;;
    --verbose)
        OPT_VERBOSE=1
        shift
        ;;
    --stdin)
        OPT_STDIN=1
        shift
        # field must be one of actors director or another valid column from imdb table  and be followed by data on STDIN
        FIELD="$1"
        break
        ;;
    --source)
        echo "this is to edit the source "
        vim $0
        exit
        ;;
    --mode)
        shift
        _MODE=".mode $1"
        shift
        ;;
    --column|--columns)
        shift
        # comma seperated list of column names
        _COLUMNS="$1"
        shift
        ;;
    --top|--top-voted)
        shift
        OPT_TOP_VOTED="$1"
        shift
        top_voted $OPT_TOP_VOTED
        exit
        ;;
    --top-rated)
        shift
        OPT_TOP_RATED="$1"
        shift
        top_rated $OPT_TOP_RATED
        exit
        ;;
    --for-year)
        shift
        OPT_YEAR="$1"
        shift
        movies_for_year $OPT_YEAR
        exit
        ;;
    --header)
        shift
        # on or off
        _HEADER="$1"
        shift
        ;;
    --title|--starring|--directed_by|--director|--actor|--imdbid|--year|-t|-s|-d|-a)
        FIELD=$1
        shift

        # if short form used, then expand it.
        if [[ $FIELD = -t ]]; then
            FIELD="--title"
        fi
        if [[ $FIELD = -d ]]; then
            FIELD="--director"
        fi
        if [[ $FIELD = -s ]]; then
            FIELD="--actors"
        fi
        if [[ $FIELD = --actor  || $FIELD = --starring ]]; then
            FIELD="--actors"
        fi
        if [[ $FIELD = -a ]]; then
            FIELD="--actors"
        fi
        if [[ $FIELD = "--directed_by" ]]; then
            FIELD="--director"
        fi
        # currently we are just overwriting previous, we could append TODO
        PATT=$1

        # remove start of string
        FIELD=${FIELD#--}
        if [[ -z "$PATT" ]]; then
            echo "Please enter a $FIELD"
            read PATT
        else
            shift
        fi
        if [[ -z "$_FILTER" ]]; then
            #_FILTER=" $FIELD like '%$PATT%' "
            _FILTER=" $FIELD $_MYOPERATOR \"${_MYWC}$PATT${_MYWC}\" "
        else
            _FILTER=" $_FILTER and  $FIELD $_MYOPERATOR \"${_MYWC}$PATT${_MYWC}\" "
        fi
        #echo "QUERY is $FIELD = $PATT"
        $RDEBUG "QUERY is $_FILTER"
        ;;
    *)
        echo reached here wrong option
        shift
    ;;
esac
done
if [[ -n "$OPT_STDIN" ]]; then
    cnt=0
    # TODO are we ignoring the others, we should OR them in a bracket
    while IFS='' read line
    do
        (( cnt == 0 )) && {
        echo "$FIELD : $line"
            PATT="$line"
        }
        (( cnt++ ))
    done
    [[ -z "$PATT" ]] && { print "Error: STDIN expected." 1>&2; exit 1; }
    _FILTER=" $FIELD $_MYOPERATOR \"${_MYWC}$PATT${_MYWC}\" "
fi
if [[ -z "$FIELD" ]]; then
    echo "Select field to search on:"
    echo "${INDENT2}d    directed by"
    echo "${INDENT2}t    title"
    echo "${INDENT2}s    starring"
    echo "${INDENT2}i    imdbId"
    echo ""
    echo -n "Enter Choice: "
    read -k ans ; 
    case $ans in
        d) FIELD="director"
            ;;
        t) FIELD="title"
            ;;
        s) FIELD="actors"
            ;;
        i) FIELD="imdbId"
            ;;
        *) echo "Error in choice: $ans not valid. "
            exit
            ;;
    esac
    echo
    echo -n "Enter pattern for $FIELD: "
    read PATT
    _FILTER=" $FIELD $_MYOPERATOR \"${_MYWC}$PATT${_MYWC}\" "
fi
#echo "Query is $FIELD = $PATT"
$RDEBUG "QUERY is $_FILTER"
$RDEBUG " _columns are $_COLUMNS "

cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/imdbdata/ || exit


sqlite3 imdb.sqlite <<!
$_MODE
.header $_HEADER
select $_COLUMNS from imdb where $_FILTER ;
!
