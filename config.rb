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
	    puts "config"

	    # Locate a config file
	    file = locate_config

	    if file != nil
		puts "Loading config..."
		@config = YAML.load_file(file)
	    end
	end
	
	def save_config
	end

	private
	def locate_config
	    location = [
	    './.workloggerrc',
	    '~/.workloggerrc',
	    '~/.worklogger/config',
	    '/etc/worklogger/config'
	    ]

	    location.each do |loc|
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
