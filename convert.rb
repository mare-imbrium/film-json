#!/usr/bin/env ruby -w
# ----------------------------------------------------------------------------- #
#         File: convert.rb
#  Description: reads up json files, uploads into table
#    Origingally, meant to convert to insert sqls, but due to single and double quotes, and other
#    characters, too much of work and possible bugs. So we directly insert into db.
#       Author:  r kumar
#         Date: 2015-11-01 - 18:38
#  Last update: 2016-01-03 18:58
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

# we should try to just generate sql statements and not write in
# The problem with this approach is that the plot data often has quotes in it
# and possibly other data, and i don't want to get into the hell of edge cases.
# We should let the database driver handle that crap.
def generate_insert_statements table, hash
    str = "INSERT INTO #{table} ("
    qstr = [] # question marks
    fields = [] # field names
    bind_vars = [] # values to insert
    hash.each_pair { |name, val| 
      fields << name
      #bind_vars << val
      bind_vars << %Q["#{val}"] 
      qstr << "?"
    }
    fstr = fields.join(",")
    str << fstr
    str << ") values ("
    #str << qstr.join(",")
    str << bind_vars.join(",")
    str << ");"
    #puts str
    # 2010-09-12 11:42 removed splat due to change in sqlite3 1.3.x
    #@db.execute(str, bind_vars)
    #rowid = @db.get_first_value( "select last_insert_rowid();")
    #return rowid
    return str

end
# recieves an array of json strings, one for each movie
# which are inserted into db and table
def table_insert_hash db, table, array
  $stderr.puts "inside table_insert_hash "
  array.each do |hash|
    str = "INSERT OR IGNORE INTO #{table} ("
    qstr = [] # question marks
    fields = [] # field names
    bind_vars = [] # values to insert
    hash.each_pair { |name, val| 
      fields << name
      bind_vars << val
      qstr << "?"
    }
    fstr = fields.join(",")
    str << fstr
    str << ") values ("
    str << qstr.join(",")
    str << ");"
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
    hash["imdbVotes"] = hash["imdbVotes"].gsub(",","") if hash["imdbVotes"]
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
        $stderr.puts "Please pass a filename containing imdbids, or pass the imdb ids"
        exit 1
      end
    end

  ensure
  end
end
