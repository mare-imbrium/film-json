# extract imdb codes from an imdb file
# ----------------------------------------------------------------------------- #
#         File: extractinternal.sh
#  Description: 
#       pass file name to this script and save in files.list
#       Author: j kepler  http://github.com/mare-imbrium/canis/
#         Date: 2015-11-07 - 14:09
#      License: MIT
#  Last update: 2015-11-07 14:14
# ----------------------------------------------------------------------------- #
#  YFF Copyright (C) 2012-2014 j kepler

grep -o -h 'href="/title/tt[0-9]*' "$1" | cut -f3 -d'/'
