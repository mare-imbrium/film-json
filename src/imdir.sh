#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: imdir.sh
# 
#         USAGE: imdir.sh [pattern]
# 
#   DESCRIPTION: shows movies for a director. takes a pattern or part of name and uses FZF to allow
#       filtering / selection of name. Source is imdb database (json/omdb api).
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#         TODO : combine with actor so one file.
#         what about allowing user to select a film with fzf and see details for that film
#         Should we try linking to the wiki?
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 12/25/2015 11:21
#      REVISION:  2016-01-23 21:10
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
        --html)   shift
            OPT_HTML=1
            _MODE=".mode html"
            ;;
        --debug)        shift
            OPT_DEBUG=1
            OPT_VERBOSE=1
            ;;
        -h|--help)
            cat <<-!
            $0 Version: 0.1.0 Copyright (C) 2015 jkepler
            This program prints movies of given director. Allows fuzzy selection from a list of directors.
            Takes one optional argument which is pattern to filter list of directors.

            Options:
            --columns <columns>        comma separated list of columns to display
            --mode   <mode>            <lines|tabs|html|csv|json> sqlite mode. default is lines
            --brief                    show only title and year
            --header  <on | off>       show headers or not
            --html                     print to html and open using w3m

!
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
CRIT=$( cat ./director.list | fzf --query="$1" -1 -0 )
[[ -z "$CRIT" ]] && { echo "Error: director blank." 1>&2; exit 1; }
SQLITE=$(brew --prefix sqlite)/bin/sqlite3
MYDATABASE="../imdb.sqlite"
MYCOL=director
MYTABLE=imdb
if [[ -n "$OPT_VERBOSE" ]]; then
echo "== $CRIT"
fi
if [[ ! -f "$MYDATABASE" ]]; then
    echo "File: $MYDATABASE not found"
    exit 1
fi
if [[ -n "$OPT_DEBUG" ]]; then
    echo "select $_COLUMNS from $MYTABLE where $MYCOL = ${CRIT} order by year;"
fi
RESULT=$( $SQLITE $MYDATABASE <<!
$_MODE
.header $_HEADER
  SELECT $_COLUMNS FROM $MYTABLE WHERE $MYCOL = "${CRIT}" ORDER BY year ;;
!
)
if [[ -z "$OPT_HTML" ]]; then
    echo "$RESULT"
else
    OUTFILE=tmp.html
    echo "<HTML><TABLE BORDER=1>" > $OUTFILE
    echo "$RESULT" >> $OUTFILE
    echo "</TABLE></HTML>" >> $OUTFILE
    w3m $OUTFILE
fi
