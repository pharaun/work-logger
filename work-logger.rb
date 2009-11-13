#!/usr/bin/env ruby
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

class Work_logger

    def initialize
	builder = Gtk::Builder.new
	builder.add_from_file('view/work_log.glade')

	@window = builder.get_object('work_logger')

	# File menu
	@new = builder.get_object('new')
	@open = builder.get_object('open')
	@close = builder.get_object('close')
	@quit = builder.get_object('quit')
	
	# Edit menu
	@undo = builder.get_object('undo')
	@redo = builder.get_object('redo')
	@cut = builder.get_object('cut')
	@copy = builder.get_object('copy')
	@paste = builder.get_object('paste')
	@delete = builder.get_object('delete')
	@clear_all = builder.get_object('clear_all')
	@select_all = builder.get_object('select_all')

	# Help menu
	@about = builder.get_object('about')

	# Toolbar
	@back = builder.get_object('back')
	@date = builder.get_object('date')
	@today = builder.get_object('today')
	@forward = builder.get_object('forward')
	@save_entry = builder.get_object('save_entry')
	
	# Main view & Status Bar	
	@textview = builder.get_object('textview')
	@statusbar = builder.get_object('statusbar')
	
    end


    def run
	@window.show_all
	Gtk.main
    end


end
