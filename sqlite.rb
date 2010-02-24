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

	    schema = %(
		PRAGMA auto_vacuum = 1;
		PRAGMA encoding = "UTF-8";
		PRAGMA user_version = 1;
		
		-- Work log entry table
		-- date is stored in "Modified Julian Day Number"
		--      From Nov 17, 1858
		CREATE TABLE logs (
		    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
		    date INTEGER NOT NULL,
		    entry TEXT NOT NULL
		);
	    )

	    @db.execute_batch(schema)
	end
    end


    def open(filename)
	if File.exists?(filename)
	    if File.readable?(filename)
		if File.writable?(filename)
		    @db = SQLite3::Database.open(filename)

		    # Check the DB schema version - Need to be same as
		    # in the create function above
		    user_version = @db.execute("PRAGMA user_version;")
		    if (user_version.to_s).to_i != 1
			@db.close
			@db = nil

			raise RuntimeError, "Wrong schema version!", caller
		    end
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


    def open?
	return !@db.nil?
    end


    def file_regex
	return "*.sqlite"
    end


    def check_filename(filename)
	if filename == nil
	    raise RuntimeError, "Nil filename!", caller
	elsif filename.empty?
	    raise RuntimeError, "Empty filename!", caller
	elsif filename =~ /^.+\.sqlite/
	    return filename
	else
	    return "#{filename}.sqlite"
	end
    end


    def fetch_text_entry(date)
	if @db.nil?
	    raise IOError, "Database is not open!", caller
	else
	    sql = "SELECT entry FROM logs WHERE date = ?"
	    text = @db.execute(sql, date.mjd)

	    return text.to_s
	end
    end


    def store_text_entry(date, entry)
	if @db.nil?
	    raise IOError, "Database is not open!", caller
	else
	    sql = "SELECT id FROM logs WHERE date = ?"
	    id = @db.execute(sql, date.mjd)
	    puts "id: #{id}"
	    if (id[0]).nil?
		sql = "INSERT INTO logs (date, entry) VALUES (?, ?)"
		@db.execute(sql, date.mjd, entry)
	    else
		sql = "UPDATE logs SET entry = ? WHERE id = ?"
		@db.execute(sql, entry, id)
	    end
	end
    end
end
