#!/usr/bin/env ruby -w
# encoding: utf-8
# downloads film data in json format based on imdb id 
#  reads imdbids from a file files.list
#  and writes to same dir.
#
#  TODO : put output files in a subdir to avoid clutter
#  check size of tt id. if less than 9 pad with 0's. if more remove zeros
#   check for " and remove everything after.
#  TODO check if exists prior to calling. Collect only new ones in an array and call for those.
#  This way we know how many there are to do.
#  Or maybe have a program which reduces files.list to only those not yet downloaded.
#
require 'net/http'
require 'uri'

# this contains imdb id's one per line, to download
inputfile = "files.list"


CLEAR      = "\e[0m"
BOLD       = "\e[1m"
BOLD_OFF       = "\e[22m"
RED        = "\e[31m"
ON_RED        = "\e[41m"
GREEN      = "\e[32m"
YELLOW     = "\e[33m"
BLUE       = "\e[1;34m"

ON_BLUE    = "\e[44m"
REVERSE    = "\e[7m"
UNDERLINE    = "\e[4m"

def warning str
  $stderr.print "#{RED}#{str}#{CLEAR}"
end
def bold str
  $stdout.print "#{BOLD}#{YELLOW}#{str}#{CLEAR}"
end
def green str
  $stdout.print "#{BOLD}#{GREEN}#{str}#{CLEAR}"
end

def check_len id
  return id if id.size == 9
  sz = id.size
  if sz < 9
    green "Modifying id #{id} which is #{sz} "
    id.insert(2, "0"*(9-sz) )
    green "New id  #{id} which is #{id.size} \n"
  else
    id = id[0,9]
  end
  return id
end

def already_downloaded imdb_id
  filename = imdb_id + ".json"
  if File.exist? filename
    warning "File #{filename} exists."
    # read up the file and print the movie name and year, we just want to know which one it was
    str = File.read(filename)
    parts = str.split('","')
    name = parts[0].split('":"').last
    year = parts[1].split('":"').last
    print "  #{year}."
    warning "#{RED} #{name} #{CLEAR}   \n"
    return true
  end
  return false
end
def parse_response str
    parts = str.split('","')
    name = parts[0].split('":"').last
    year = parts[1].split('":"').last
    return name, year
end
# retrieve json file based on imdbid
# @return true if downloaded a file
# @return false if file already exists
def retrieve imdb_id
  #http://www.omdbapi.com/?i=tt0133093&plot=short&r=json
  host = "http://www.omdbapi.com/"
  #parms = "title=Matrix"
  #imdb_id = "tt0133093"
  if already_downloaded imdb_id
    return false
  end
  filename = imdb_id + ".json"

  # Other parms
  #parms = parms + "&actors=S&format=JSON"
  parms = "#{imdb_id}&plot=full&r=json"

  url = "#{host}?i=#{parms}"
  print "#{url} .."

  # FIXME sometimes some characters after the number cause a crash such as double quote
  #  or less than.
  uri = URI(url)

  response = Net::HTTP.get_response(uri)

  puts response.body
  name, year = parse_response response.body
  bold "#{year}  #{name} \n"
  # can we check response body for false and error
  # "Incorrect IMDb ID"
  File.open(filename, 'w') {|f| f.write(response.body) } 
  return true
end


#imdb_id = "tt0133093"
#retrieve imdb_id

ctr = 0
total = 0
list = []
# load new titles into an array
File.foreach(inputfile) { |line| 
  line = line.chomp
  line = check_len(line)
  unless already_downloaded line
    list << line
  end
}
if list.size == 0
  bold "No files to download.\n"
  exit 1
end

puts
bold "Total todo: #{list.size} ============ \n"
puts
total = list.size
list.each do  |line|
  print  "#{line}  "
  st = retrieve line
  if st
    ctr += 1
    print "\n======= #{ctr} of #{total} ======= \n"
    sleep(2) if st
  end
end

