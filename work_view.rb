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

class Work_view

    def initialize(controller)
	@builder = Gtk::Builder.new
	@builder.add_from_file('view/work_log.glade')

	@controller = controller

	# Initalize other components
	textview_init
	date_init
	signal_init

	insensitive
    end


    def textview_init
	textview = @builder.get_object('textview')
	text_buffer = Gtk::TextBuffer.new
	textview.buffer = text_buffer

	# Signals
	text_buffer.signal_connect('changed') {update_statusbar}
	text_buffer.signal_connect('mark-set') {update_statusbar}
	textview.signal_connect('move-cursor') {update_statusbar}

	# Text change signals
	text_buffer.signal_connect('insert_text') do
	    @controller.text_changed = true
	end
	text_buffer.signal_connect('delete_range') do
	    @controller.text_changed = true
	end
	text_buffer.signal_connect('begin_user_action') do
	    @controller.user_action = true
	end

	update_statusbar
    end


    def date_init
	date = @controller.date_today

	# Setup the date_dropdown combobox
	date_dropdown = @builder.get_object('date')
	list_store = Gtk::ListStore.new(String)
	date_dropdown.model = list_store
	date_dropdown.text_column = 0

	# Set the date in the combobox
	(list_store.append())[0] = date.to_s
	date_dropdown.active = 0

	# TODO: Calendar dropdown
    end


    def signal_init
	window = @builder.get_object('work_logger')

	##############################
	# File menu
	##############################
        new = @builder.get_object('new')
        open = @builder.get_object('open')
        close = @builder.get_object('close')
        quit = @builder.get_object('quit')

	new.signal_connect('activate') do
	    filename = file_choicer("New Database", true)
	    if !filename.nil?
		@controller.new_database(filename)
		sensitive
	    end
	end

	open.signal_connect('activate') do
	    filename = file_choicer("Open Database", false)
	    if !filename.nil?
		@controller.open_database(filename)
		sensitive
	    end
	end

	close.signal_connect('activate') do
	    @controller.close_database
	    insensitive
	end

	quit.signal_connect('activate') { quit_app }
	window.signal_connect('destroy') { quit_app }


	##############################
	# Edit menu
	##############################
        cut = @builder.get_object('cut')
        copy = @builder.get_object('copy')
        paste = @builder.get_object('paste')
        clear_all = @builder.get_object('clear_all')
        select_all = @builder.get_object('select_all')

	textview = @builder.get_object('textview')
	buffer = textview.buffer

	cut.signal_connect('activate') do
	    textview.signal_emit('cut_clipboard')
	end

	copy.signal_connect('activate') do
	    textview.signal_emit('copy_clipboard')
	end

	paste.signal_connect('activate') do
	    textview.signal_emit('paste_clipboard')
	end

	clear_all.signal_connect('activate') do
	    buffer.set_text("")
	end

	select_all.signal_connect('activate') do
	    buffer.place_cursor(buffer.end_iter)
	    buffer.move_mark(buffer.get_mark('selection_bound'), buffer.start_iter)
	end


	##############################
	# Help menu
	##############################
        about = @builder.get_object('about')

	about.signal_connect('activate') do
	    create_about.show
	end


	##############################
	# Toolbar
	##############################
        back = @builder.get_object('back')
        today = @builder.get_object('today')
        forward = @builder.get_object('forward')
        save_entry = @builder.get_object('save_entry')

	back.signal_connect('clicked') do
	    @controller.date_back

	    # TODO: Controller needs to check
	    #
	    # text_changed?
	    # date_update
	end

	today.signal_connect('clicked') do
	    @controller.date_today

	    # TODO: Controller needs to check
	    #
	    # text_changed?
	    # date_update
	end

	forward.signal_connect('clicked') do
	    @controller.date_forward

	    # TODO: Controller needs to check
	    #
	    # text_changed?
	    # date_update
	end

	save_entry.signal_connect('clicked') do
	    @controller.save_entry(buffer.get_text)

	    @controller.text_changed = false
	    @controller.user_action = false
	end
    end


    def date_update(date)
	date_dropdown = @builder.get_object('date')
	model = date_dropdown.model

	# Reset the date in the dropdown
	model.clear
	model.append()[0] = date.to_s
	date_dropdown.active = 0
    end


    def update_textview(text)
	textview = @builder.get_object('textview')
	buffer = textview.buffer

	buffer.set_text(text)

	# Grab focus
	textview.grab_focus
    end


    def get_text
	textview = @builder.get_object('textview')
	buffer = textview.buffer

	return buffer.get_text
    end


    def save_text?
	window = @builder.get_object('work_logger')
	dialog = Gtk::MessageDialog.new(window,
					Gtk::Dialog::DESTROY_WITH_PARENT,
					Gtk::MessageDialog::QUESTION,
					Gtk::MessageDialog::BUTTONS_YES_NO,
				    "Do you want to save the current Log Entry?")

	ret = (dialog.run == Gtk::Dialog::RESPONSE_YES) ? true : false

	# TODO: controller needs to update the db if this entry is true
	# and also set up other stuff
	#
	# @db.store_text_entry(@date, (@textview.buffer).get_text)

	dialog.destroy

	@controller.text_changed = false
	@controller.user_action = false

	return ret
    end


    def quit_app
	window = @builder.get_object('work_logger')
	@controller.close_database

	Gtk.main_quit
    end


    def update_statusbar
	statusbar = @builder.get_object('statusbar')
	textview = @builder.get_object('textview')
	buffer = textview.buffer

	if !@statusbar_id.nil?
	    statusbar.pop(@statusbar_id)
	end

	iter = buffer.get_iter_at_mark(buffer.get_mark("insert"))

	# TODO: Add in "save/unsaved" status
	@statusbar_id = statusbar.push(statusbar.get_context_id("textview"), \
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
	window = @builder.get_object('work_logger')

	if new
	    mode = Gtk::FileChooser::ACTION_SAVE
	    button = [Gtk::Stock::SAVE, Gtk::Dialog::RESPONSE_OK]
	else
	    mode = Gtk::FileChooser::ACTION_OPEN
	    button = [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_OK]
	end

	dialog = Gtk::FileChooserDialog.new(title,
					    window,
					    mode,
					    nil,
					    [Gtk::Stock::CANCEL,
						Gtk::Dialog::RESPONSE_CANCEL],
					    button)

	# File filter
	filter = Gtk::FileFilter.new
	filter.add_pattern(@controller.file_regex)
	filter.name = "Database File"
	dialog.filter = filter

	if dialog.run == Gtk::Dialog::RESPONSE_OK
	    filename = dialog.filename
	end
	dialog.destroy

	return @controller.santize_filename(filename)
    end


    def insensitive
	button_hbox = @builder.get_object('button_hbox')
	scrolled = @builder.get_object('scrolled_window')
	edit_menu = @builder.get_object('edit')
	close = @builder.get_object('close')

	button_hbox.sensitive = false
	scrolled.sensitive = false
	edit_menu.sensitive = false
	close.sensitive = false
    end


    def sensitive
	button_hbox = @builder.get_object('button_hbox')
	scrolled = @builder.get_object('scrolled_window')
	edit_menu = @builder.get_object('edit')
	close = @builder.get_object('close')

	textview = @builder.get_object('textview')

	button_hbox.sensitive = true
	scrolled.sensitive = true
	edit_menu.sensitive = true
	close.sensitive = true

	# Grab focus
	textview.grab_focus
    end


    def show_all
	window = @builder.get_object('work_logger')

	window.show_all
    end
end
