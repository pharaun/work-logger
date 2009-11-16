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

    def initialize(db)
	@db = db

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
	@date_dropdown = builder.get_object('date')
	@today = builder.get_object('today')
	@forward = builder.get_object('forward')
	@save_entry = builder.get_object('save_entry')

	# Main view & Status Bar
	@textview = builder.get_object('textview')
	@statusbar = builder.get_object('statusbar')

	# Activate/inactivate
	@button_hbox = builder.get_object('button_hbox')
	@scrolled_window = builder.get_object('scrolled_window')
	@edit_menu = builder.get_object('edit')


	# Initalize the signals
	textview_init
	date_init
	signal_init
	inactive
    end


    def textview_init
	text_buffer = Gtk::TextBuffer.new
	@textview.buffer = text_buffer

	##############################
	# Text buffer/viewer signals
	##############################
	text_buffer.signal_connect('changed') {update_statusbar}
	text_buffer.signal_connect('mark-set') {update_statusbar}
	@textview.signal_connect('move-cursor') {update_statusbar}

	update_statusbar
    end


    def date_init
	@date = Date.today(Date::ENGLAND)

	# Setup the date_dropdown combobox
	list_store = Gtk::ListStore.new(String)
	@date_dropdown.model = list_store
	@date_dropdown.text_column = 0

	# Date
	(list_store.append())[0] = @date.to_s
	@date_dropdown.active = 0
    end


    def signal_init
	##############################
	# File menu
	##############################
	@new.signal_connect('activate') do
	    filename = file_choicer("New Database", true)
	    if !filename.nil?
		@db.create(filename)
		active
	    end
	end

	@open.signal_connect('activate') do
	    filename = file_choicer("Open Database", false)
	    if !filename.nil?
		@db.open(filename)

		date_update
		active
	    end
	end

	@close.signal_connect('activate') do
	    @db.close
	    inactive
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
	@about.signal_connect('activate') do
	    create_about.show
	end

	##############################
	# Toolbar
	##############################
	@back.signal_connect('clicked') do
	    @date = @date - 1
	    date_update
	end

	@today.signal_connect('clicked') do
	    @date = Date.today(Date::ENGLAND)
	    date_update
	end

	@forward.signal_connect('clicked') do
	    @date = @date.next
	    date_update
	end

	@save_entry.signal_connect('clicked') do
	    puts "Save the current entry to the db"
	end
    end


    def date_update
	# Date
	(@date_dropdown.model).clear
	((@date_dropdown.model).append())[0] = @date.to_s
	@date_dropdown.active = 0

	# See if sqldb has an entry for that day
	# update textview
	result = @db.fetch_text_entry(@date)
	if !result.nil?
	    (@textview.buffer).set_text(result)
	end
    end


    def quit
	begin
	    @db.close
	rescue IOError
	    puts "Ignoring - IOError from @db.close"
	end

	Gtk.main_quit
    end


    def update_statusbar
	if !@statusbar_id.nil?
	    @statusbar.pop(@statusbar_id)
	end

	buffer = @textview.buffer
	iter = buffer.get_iter_at_mark(buffer.get_mark("insert"))

	# TODO: Add in "save/unsaved" status
	@statusbar_id = @statusbar.push(@statusbar.get_context_id("textview"), \
	    "Line: #{iter.line + 1}, Column: #{iter.line_offset + 1}")
    end


    def create_about
	about = Gtk::AboutDialog.new

	about.name = "WorkLogger"
	about.program_name = "Work Logger"

	about.version = "0.1 - Alpha"
	about.copyright = "Copyright (c) 2009, Anja Berens"

	about.license = "You can redistribute it and/or modify it under the terms of the GPL's licence."
	about.wrap_license = true

	about.website = "http://amrutlar.com/work_logger"

	about.authors = ["Anja Berens"]
	about.documenters = ["Anja Berens"]

	# Signal
	about.signal_connect('response') {about.hide_all}

	return about
    end


    def file_choicer(title, new)
	if new
	    mode = Gtk::FileChooser::ACTION_SAVE
	    button = [Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_OK]
	else
	    mode = Gtk::FileChooser::ACTION_OPEN
	    button = [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_OK]
	end

	dialog = Gtk::FileChooserDialog.new(title,
					    @window,
					    mode,
					    nil,
					    [Gtk::Stock::CANCEL,
						Gtk::Dialog::RESPONSE_CANCEL],
					    button)

	# File filter
	filter = Gtk::FileFilter.new
	filter.add_pattern(@db.file_regex)
	filter.name = "Database File"
	dialog.filter = filter

	if dialog.run == Gtk::Dialog::RESPONSE_OK
	    filename = dialog.filename
	end
	dialog.destroy

	return @db.check_filename(filename)
    end


    def inactive
	@button_hbox.sensitive = false
	@scrolled_window.sensitive = false
	@edit_menu.sensitive = false
	@close.sensitive = false
    end


    def active
	@button_hbox.sensitive = true
	@scrolled_window.sensitive = true
	@edit_menu.sensitive = true
	@close.sensitive = true
    end


    def run
	@window.show_all
	Gtk.main
    end
end
