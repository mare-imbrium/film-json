#!/usr/bin/env bash 
#===============================================================================
#
#          FILE: crosscheck.sh
# 
#         USAGE: ./crosscheck.sh 
# 
#   DESCRIPTION: take movie names from imdb interface list with year and check if we have it in
#            our omdb database
# 
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (), 
#  ORGANIZATION: 
#       CREATED: 01/03/2016 12:56
#      REVISION:  2016-01-03 19:41
#===============================================================================


source ~/bin/sh_colors.sh
APPNAME=$( basename $0 )
export TAB=$'\t'

ScriptVersion="1.0"

#===  FUNCTION  ================================================================
#         NAME:  usage
#  DESCRIPTION:  Display usage information.
#===============================================================================
function usage ()
{
	cat <<- EOT

  Usage :  ${0##/*/} [options] [--] 

  Options: 
  -h|--help       Display this message
  -v|--version    Display script version
  -V|--verbose    Display processing information
  --no-verbose    Suppress extra information
  --debug         Display debug information

	EOT
}    # ----------  end of function usage  ----------


#-------------------------------------------------------------------------------
# handle command line options
#-------------------------------------------------------------------------------
OPT_VERBOSE=
OPT_DEBUG=
OPT_DIRECTOR=
while [[ $1 = -* ]]; do
case "$1" in
    -V|--verbose)   shift
                     OPT_VERBOSE=1
                     ;;
    -d|--director)   shift
                     OPT_DIRECTOR=1
                     ;;
    --no-verbose)   shift
                     OPT_VERBOSE=
                     ;;
    --debug)        shift
                     OPT_DEBUG=1
                     ;;
    -h|--help)
        usage
        exit
    ;;
    *)
        echo "Error: Unknown option: $1" >&2   # rem _
        echo "Use -h or --help for usage" 1>&2
        exit 1
        ;;
esac
done

if [[ -n "$OPT_DIRECTOR" ]]; then
    echo -e "DIRECTOR SEARCH" 1<&2
    fzdir.sh "$@" | cut -f1 > t.t
    less t.t
else
    echo -e "ACTOR SEARCH" 1<&2
    fzactor.sh "$@" | cut -f1 > t.t
fi
while IFS='' read line
do
    #echo -e "$line"
    # we still aren't taking care of (????/I) cases, too many !
    year=$( echo "$line"  | sed 's/.*(\([0-9][0-9][0-9][0-9]\).*/\1/' )
    if [[ -z "$year" ]]; then
        # this is one of those 2011/I cases
        year=$( echo "$line"  | sed 's/.*(\([0-9][0-9][0-9][0-9]\)\/.*/\1/' )
    fi
    title=$( echo "$line" | sed 's/\(.*\) ([0-9][0-9][0-9][0-9].*/\1/' )
    echo ":$title:$year:"
    cu.sh "$title" "$year"
done < t.t
#rm t.t
