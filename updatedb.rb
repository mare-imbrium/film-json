#!/usr/bin/env ruby -w
# ----------------------------------------------------------------------------- #
#         File: update.rb
#  Description: reads up json files, updates table.
#    This is mostly required for new movies which don't have oscar and other award info updated yet.
#    Sometimes the plot also changes.
#       Author:  r kumar
#         Date: 2015-11-01 - 18:38
#  Last update: 2015-12-29 10:04
#      License: MIT License
# ----------------------------------------------------------------------------- #
#

require 'json'
require 'sqlite3'

dbname = "imdb.sqlite"
@db = SQLite3::Database.new(dbname)
# this contains imdb ids one per line, to read up and insert into DB
# It does not check for exists, and will crash if record already exists
# TODO we cannot be picking up json files which have Response = Error in it.
# Also how do we handle dupes without having to check ? retrieve has already checked.
#    should it create an output file so we can use that only.
inputfile = "files.list"

# recieves an array of json strings, one for each movie
# which are inserted into db and table
def table_insert_hash db, table, array
  #$stderr.puts "inside table_insert_hash "
  array.each do |hash|
    #str = "INSERT OR IGNORE INTO #{table} ("
    str = "UPDATE #{table} SET "
    qstr = [] # question marks
    bind_vars = [] # values to insert
    imdbid = hash.delete "imdbID"
    hash.each_pair { |name, val| 
      bind_vars << val
      qstr << " #{name}=? "
    }
    #str << fstr
    #str << ") values ("
    str << qstr.join(",")
    str << %Q[ WHERE imdbID = '#{imdbid}' ]
    str << ";"
    $stderr.puts "#{hash["imdbID"]}    #{hash["Title"]} "
    #puts " #{hash["Title"]} #{hash["imdbID"]} "
    db.execute(str, bind_vars)
    #rowid = @db.get_first_value( "select last_insert_rowid();")
    #return rowid
  end
end

# read imdb id's from a file into an array
def process_file_containing_imdbids inputfile
  filename = inputfile
  file = File.new(filename, "r");
  array=file.readlines;
  file.close
  return array
end

# ------------------
#  file contains an imdbid on each line
#  This points to a file like tt001111.json.
#  We read this file into a hash and push this hash onto an array of hashes.
# ------------------
# recieve an array of imdb id's which are then read up from disk into an array of hashes
def process_imdbarray array
hasharray = []
array.each_with_index do |e, i| 
  e = e.chomp
  if e.index(".json").nil?
    e += ".json"
  end
  unless File.exist?(e)
    puts "File #{e} not found. Please correct file name\n"
    next
  end
  # file contains just one line of JSON.
  File.open(e).each { |line|
    hash = JSON.parse(line)
    if hash["Response"] == "False"
      puts " ======== #{e} has error. ignoring ... ======"
      next
    end
    hash.delete "Response"
    # added 2015-11-07 - I don't need this, large field
    hash.delete "Poster"
    # remove commas from votes so we can sort on it.
    hash["imdbVotes"] = hash["imdbVotes"].gsub(",","")
    #puts hash.to_s
    $stderr.print " #{hash["Title"]}  #{hash["Year"]}     #{e}"
    $stderr.puts 
    hasharray << hash
    #str = generate_insert_statements "imdb", hash
    #puts str
    #print hash.keys
  }

end
table_insert_hash @db, "imdb", hasharray
@db.close
end

if __FILE__ == $0
  filename = nil
  $verbose = false
  begin
    # http://www.ruby-doc.org/stdlib/libdoc/optparse/rdoc/classes/OptionParser.html
    require 'optparse'
    options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: #{$0} [options]"
      opts.on("-f", "--filename imdbid.list", String, "File containing IMDB ids") do |l|
        filename = l
      end

      opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
        options[:verbose] = v
        $verbose = v
      end
    end.parse!

    p options
    p ARGV
    if ARGV.size > 0
      # we have ttcodes
      $stderr.puts "processing ttcodes #{ARGV}"
      process_imdbarray ARGV
    else
      # we should have a filename
      if filename
        $stderr.puts "processing filename #{filename}"
        array = process_file_containing_imdbids filename
        process_imdbarray array
      else
        $stderr.puts "Please pass a filename containing imdbids using -f or --filename, or pass the imdb ids"
        exit 1
      end
    end

  ensure
  end
end
