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

	# Initalize the signals
	textview_init
	date_init
	signal_init
    end


    def textview_init
	text_buffer = Gtk::TextBuffer.new
	@textview.buffer = text_buffer

	##############################
	# Text buffer/viewer signals
	##############################
    end

    def date_init

    end


    def signal_init
	##############################
	# File menu
	##############################
	@new.signal_connect('activate') do
	    puts "Create a new sqlite db"
	end

	@open.signal_connect('activate') do
	    puts "Open the selected sqlite db"
	end

	@close.signal_connect('activate') do
	    puts "Tidying up and close the currently open sqlite db"
	end

	@quit.signal_connect('activate') { quit }
	@window.signal_connect('destroy') { quit }

	##############################
	# Edit menu
	##############################
	@undo.signal_connect('activate') do
	    puts "Undo the previous action on the textview"
	end

	@redo.signal_connect('activate') do
	    puts "Redo the previous action on the textview"
	end

	@cut.signal_connect('activate') do
	    @textview.signal_emit('cut_clipboard')
	end

	@copy.signal_connect('activate') do
	    @textview.signal_emit('copy_clipboard')
	end

	@paste.signal_connect('activate') do
	    @textview.signal_emit('paste_clipboard')
	end

	@clear_all.signal_connect('activate') do
	    (@textview.buffer).set_text("")
	end

	@select_all.signal_connect('activate') do
	    buffer = @textview.buffer

	    buffer.place_cursor(buffer.end_iter)
	    buffer.move_mark(buffer.get_mark('selection_bound'), buffer.start_iter)
	end

	##############################
	# Help menu
	##############################
	@about.signal_connect('activate') { about_dialog }

	##############################
	# Toolbar
	##############################
	@back.signal_connect('clicked') do
	    puts "Go back one day on the textview"
	end

	@today.signal_connect('clicked') do
	    puts "Go to today on the textview"
	end

	@forward.signal_connect('clicked') do
	    puts "Go forward one day on the textview"
	end

	@save_entry.signal_connect('clicked') do
	    puts "Save the current entry to the db"
	end
    end


    def quit
	puts "Tidying up and quitting the program"
	Gtk.main_quit
    end


    def about_dialog
	puts "The about dialog"
    end


    def run
	@window.show_all
	Gtk.main
    end
end
