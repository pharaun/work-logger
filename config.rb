# Work logger
#
# Copyright (c) 2009, Anja Berens
#
# You can redistribute it and/or modify it under the terms of
# the GPL's licence.
#

require 'yaml'

module Work
    class Config
	def initialize
	    # Topmost location is the first one to check/save to
	    @location = [
	    './.workloggerrc',
	    '~/.workloggerrc',
	    '~/.worklogger/config',
	    '/etc/worklogger/config'
	    ]

	    @configChanged = false

	    # Locate a config file
	    @file = locate_config

	    if @file != nil
		puts "Loading config: #{@file}"
		@config = YAML.load_file(@file)

		# If there is nothing to parse/load YAML will return "false"
		if not @config
		    @config = Hash.new
		end
	    else
		@config = Hash.new
	    end
	end
	
	def save_config
	    if @configChanged
		@configChanged = false

		if @file != nil
		    File.open( @file, 'w' ) do |out|
			YAML.dump(@config, out)
		    end
		else
		    # Select first location to save to
		    @file = @location.first
		    File.open( @file, 'w' ) do |out|
			YAML.dump(@config, out)
		    end
		end
		
		puts "Saving config: #{@file}"
	    end
	end

	attr_reader :configChanged

	# Implement some basic Hashlike operations
	def [](key)
	    return @config[key]
	end

	# Looks like we might not even need this, i'm thinking it might
	# be needed to inject this setter into the hash itself
	def []=(key, value)
	    @configChanged = true
	    @config[key] = value
	end

	private
	def locate_config
	    @location.each do |loc|
		file = File.expand_path(loc)
		
		if File.file?(file)
		    if File.readable?(file)
			return file
			break
		    else
			raise "Can't read the config file: #{file}"
		    end
		end
	    end

	    return nil
	end
    end
end
