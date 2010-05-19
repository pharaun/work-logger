# Work logger
#
# Copyright (c) 2009, Anja Berens
#
# You can redistribute it and/or modify it under the terms of
# the GPL's licence.
#
# With much thanks to "Masao Mutoh" for his "Simple Text Editor"
# which provided the inspiration and hints/guideline for this project
#

require 'gtk2'
require 'config'

module Work
    class Controller

	def initialize
	    @date = date_today

	    # Text changed indicators
	    @text_changed = false
	    @user_action = false

	    # Load up the config
	    @config = Config.new

	    # Load the "last file" type driver code
	    filetype = @config['file']['type']
	    if filetype != nil
		puts "Loading support for: #{filetype}"
		load "#{filetype}.rb"
		@db = eval("Work::#{filetype.capitalize}.new")
	    else
		puts "Exiting program for now, because adding file types support"
		puts "isn't an easy task so exiting for now"
		exit 1
	    end
	end

	attr_accessor :text_changed, :user_action


	def set_view(view)
	    @view = view

	    # At this point its not exactly the most ideal spot to put this
	    # code, but...

	    # Loads the last open file
	    file = @config['file']['last']
	    if not (file.nil?)
		if File.file?(file)
		    if File.readable?(file)
			puts "Loading: #{file}"
			open_database(file)
			@view.sensitive
		    end
		end
	    end
	end

	def date=(date)
	    text_changed?

	    @date = date

	    @view.date_update(@date)

	    result = @db.fetch_text_entry(@date)

	    if !result.nil?
		@view.update_textview(result)
	    end
	end

	def date_today
	    text_changed?

	    @date = Date.today(Date::ENGLAND)

	    if !@view.nil?
		@view.date_update(@date)

		result = @db.fetch_text_entry(@date)

		if !result.nil?
		    @view.update_textview(result)
		end
	    end

	    return @date
	end


	def date_back
	    text_changed?

	    @date = @date - 1

	    @view.date_update(@date)

	    result = @db.fetch_text_entry(@date)

	    if !result.nil?
		@view.update_textview(result)
	    end

	    return @date
	end


	def date_forward
	    text_changed?

	    @date = @date + 1

	    @view.date_update(@date)

	    result = @db.fetch_text_entry(@date)

	    if !result.nil?
		@view.update_textview(result)
	    end

	    return @date
	end


	def new_database(filename)
	    if @db.open?
		text_changed?

		@db.close
	    end

	    @db.create(filename)
	    @config['file']['last'] = filename
	    @config['file']['type'] = @db.file_type

	    @view.update_textview("")
	end


	def open_database(filename)
	    if @db.open?
		text_changed?

		@db.close
	    end

	    @db.open(filename)

	    # If last_file is nil or not the same then store the opened file
	    if @config['file']['last'] == nil
		@config['file']['last'] = filename
		@config['file']['type'] = @db.file_type
	    elsif @config['file']['last'] != filename
		@config['file']['last'] = filename
		@config['file']['type'] = @db.file_type
	    end
	    
	    @view.date_update(date_today)

	    result = @db.fetch_text_entry(@date)

	    if !result.nil?
		@view.update_textview(result)
	    end
	end


	def close_database
	    if @db.open?
		text_changed?

		@db.close

		@view.update_textview("")
	    end
	end


	def save_entry(text)
	    @db.store_text_entry(@date, text)
	end


	def text_changed?
	    if (@text_changed and @user_action)
		if @view.save_text?
		    save_entry(@view.get_text)
		end
	    end
	end


	def file_regex
	    return @db.file_regex
	end


	def santize_filename(filename)
	    begin
		return @db.check_filename(filename)
	    rescue
		return nil
	    end
	end

	def quit
	    close_database
	    @config.save_config
	end
    end
end
