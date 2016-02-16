#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: title.sh
# 
#         USAGE: title.sh <PATT>
#                title.sh --brief PATT
#                title.sh --columns "title, director, actors" PATT
# 
#   DESCRIPTION: prints details of a movie from json database given a movie title pattern.
#               Uses fzf to select a movie first
#
# 
#       OPTIONS: ---
#  REQUIREMENTS: fzf titles.list
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/25/2015 11:21
#      REVISION:  2016-01-18 11:55
#===============================================================================

OPT_VERBOSE=
OPT_DEBUG=
_MODE=".mode line"
_HEADER=" OFF "
_COLUMNS='*'
while [[ $1 = -* ]]; do
    case "$1" in
    --brief)
        _COLUMNS=" title, year, director, actors"
        shift
        ;;
    --header)
        shift
        # on or off
        _HEADER="$1"
        shift
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
        -V|--verbose)   shift
            OPT_VERBOSE=1
            ;;
        --debug)        shift
            OPT_DEBUG=1
            OPT_VERBOSE=1
            ;;
        -h|--help)
            sed -e 's/^          //'  <<-!
            $0 Version: 0.0.0 Copyright (C) 2015 jkepler
            This program prints details of a movie from the omdb api / json database. It allows fuzzy selection of title.
            Takes one optional argument which is pattern to filter list of movies.

            --brief      print only title year director and actors
            --columns    print specified columns
            --mode       use another sqlite mode such as csv tabs html json. Default is lines
            --header     off or on. prints headers. Default off.
            --refresh    refresh titles.list from which fzf filters title names

            Examples: title.sh gosford
                      title.sh --brief southpacific
                      title.sh --columns "title, director, actors" casablanca

            The title list can be obsolete. Use --refresh to refresh it if the movie doesn't show up but has 
            been added recently.
!
            exit
            ;;
        --refresh)
            cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/imdbdata/src
            ./update_fzf_lists.sh
            if [[ $MYDATABASE -nt ./title.list ]]; then
                errorstr="titles.list is out of date."
                echo errorstr
            else
                echo "titles.list is upto date"
            fi
            exit
            ;;
        *)
            echo "Error: Unknown option: $1" >&2   
            echo "Use -h or --help for usage" 1>&2
            exit 1
            ;;
    esac
done
PATT="$1"
cd /Volumes/Pacino/dziga_backup/rahul/Downloads/MOV/imdbdata/src
MYDATABASE="../imdb.sqlite"
if [[ $MYDATABASE -nt ./title.list ]]; then
    errorstr="titles.list is out of date. pls refresh using update_fzf_lists.sh"
fi
CRIT=$( cat ./titles.list | fzf --query="$1" -1 -0 )
[[ -z "$CRIT" ]] && { echo "Error: No title selected or none matched. $errorstr" 1>&2; exit 1; }
TITLE=$( echo "$CRIT" | cut -f1)
YEAR=$( echo "$CRIT" | cut -f2)
SQLITE=$(brew --prefix sqlite)/bin/sqlite3
MYCOL=title
MYTABLE=imdb
echo "got: $CRIT" 1>&2
if [[ ! -f "$MYDATABASE" ]]; then
    echo "File: $MYDATABASE not found"
    exit 1
fi
if [[ -n "$OPT_VERBOSE" ]]; then
    echo "select * from $MYTABLE where $MYCOL = ${TITLE};" 1>&2
fi
$SQLITE $MYDATABASE <<!
$_MODE
.header $_HEADER
  select * from $MYTABLE where $MYCOL = "${TITLE}" and year = "$YEAR" ;
!
