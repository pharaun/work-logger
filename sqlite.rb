#!/usr/bin/env ruby
# Work logger
#
# Copyright (c) 2009, Anja Berens
#
# You can redistribute it and/or modify it under the terms of
# the GPL's licence.
#

require 'sqlite3'

class Sqlite

    def initialize
	puts "sqlite db"
    end

    
    def create(filename)
	if File.exists?(filename)
	    raise IOError, "File already exist!", caller
	else
	    @db = SQLite3::Database.new(filename)

	    # TODO: Create the Db schema
	end
    end


    def open(filename)
	if File.exists?(filename)
	    if File.readable?(filename)
		if File.writable?(filename)
		    @db = SQLite3::Database.open(filename)

		    # TODO: Check the DB schema version
		else
		    raise IOError, "File is not writtable!", caller
		end
	    else
		raise IOError, "File is not readable!", caller
	    end
	else
	    raise IOError, "File does not exist!", caller
	end
    end


    def close
	if @db.nil?
	    raise IOError, "Database is not open!", caller
	else
	    @db.close
	    @db = nil
	end
    end


    def file_regex
	return "*.sqlite"
    end

    def check_filename(filename)
	if filename =~ /^.*\.sqlite/
	    return filename
	else
	    return "#{filename}.sqlite"
	end
    end
end
