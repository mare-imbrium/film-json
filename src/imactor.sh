#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: imactor.sh 
# 
#         USAGE: imactor.sh [pattern]
# 
#   DESCRIPTION: shows movies for a actor. takes a pattern or part of name and uses FZF to allow
#       filtering / selection of name. Source is imdb database (json/omdb api).
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/25/2015 11:21
#      REVISION:  2016-01-23 21:06
#===============================================================================

OPT_VERBOSE=
OPT_DEBUG=
_MODE=".mode line"
_HEADER=" OFF "
_COLUMNS='*'
while [[ $1 = -* ]]; do
    case "$1" in
    --brief)
        _COLUMNS=" title, year"
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
            cat <<-!
            $0 Version: 0.0.0 Copyright (C) 2015 jkepler
            This program prints movies of given actor. Allows fuzzy selection from a list of actor.
            Takes one optional argument which is pattern to filter list of actor.

            Options:
            --columns    comma separated list of columns to display
            --mode       sqlite mode. default is lines
            --brief      show only title and year
            --header     on | off

!
            # no shifting needed here, we'll quit!
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
CRIT=$( cat ./actors.list | fzf --query="$1" -1 -0 )
[[ -z "$CRIT" ]] && { echo "Error: actors blank." 1>&2; exit 1; }
SQLITE=$(brew --prefix sqlite)/bin/sqlite3
MYDATABASE="../imdb.sqlite"
MYCOL=actors
MYTABLE=imdb
if [[ -n "$OPT_VERBOSE" ]]; then
echo "== $CRIT"
fi
if [[ ! -f "$MYDATABASE" ]]; then
    echo "File: $MYDATABASE not found"
    exit 1
fi
if [[ -n "$OPT_DEBUG" ]]; then
    echo "select $_COLUMNS from $MYTABLE where $MYCOL LIKE ${CRIT} order by year;"
fi
$SQLITE $MYDATABASE <<!
$_MODE
.header $_HEADER
  SELECT $_COLUMNS FROM $MYTABLE WHERE $MYCOL LIKE "%${CRIT}%" ORDER BY year ;;
!
