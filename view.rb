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
require 'date'

module Work
    ######################################################################
    # Calendar Combo Box Entry
    ######################################################################
    class CalendarComboBoxEntry < Gtk::HBox
	type_register

	# New Signal
	DATE_UPDATE = 'date_update'
	signal_new(DATE_UPDATE,
		   GLib::Signal::RUN_FIRST,
		   nil,
		   nil,
		   Date
		  )
	def signal_do_date_update(parms)
	#	puts "Emitting this signal and someone caught it?"
	end

	def initialize
	    super

	    # Create the entry & button
	    @entry = Gtk::Entry.new
	    self.pack_start(@entry, true, true, 1)

	    @button = Gtk::Button.new
	    @button.image = Gtk::Image.new('./view/arrow.png')

	    self.pack_start(@button, false, false, 0)

	    # Connect up the listeners
	    @button.signal_connect('clicked') {on_button}
	    @entry.signal_connect('key-press-event') {on_key_or_button_press}
	    @entry.signal_connect('button-press-event') {on_key_or_button_press}

	    # Create the calendar so that when it pops up it has the right date
	    @calendar = Gtk::Calendar.new
	end

	def date=(date)
	    @entry.text = date.to_s

	    @calendar.select_month(date.month, date.year)
	    @calendar.select_day(date.day)
	end

	def clear
	    @entry.text = ""
	end

	private
	def on_key_or_button_press
	    @button.clicked
	end

	def on_button
	    window_pos = parent.parent_window.position
	    widget_pos = [@entry.allocation.x,  @entry.allocation.y]
	    shift = [0, @entry.allocation.height]

	    @cal_pos = Array.new
	    @cal_pos[0] = window_pos[0] + widget_pos[0] + shift[0]
	    @cal_pos[1] = window_pos[1] + widget_pos[1] + shift[1]

	    # Creating the Dialog box & Calendar
	    @dialog = Gtk::Dialog.new(nil,
				      nil,
				      Gtk::Dialog::MODAL | Gtk::Dialog::NO_SEPARATOR)
	    @dialog.decorated = false
	    @dialog.move(@cal_pos[0], @cal_pos[1]) # Probably ignored
	    @dialog.vbox.pack_start(@calendar, false, false)

	    # Listeners
	    @calendar.signal_connect('day-selected', 'day-selected') {|inst, sig| on_select(inst, sig)}
	    @calendar.signal_connect('month-changed', 'month-changed') {|inst, sig| on_select(inst, sig)}
	    @dialog.signal_connect('button-press-event') {on_button_press}

	    # Select the correct date
	    date = Date.parse(@entry.text)
	    @calendar.select_month(date.month, date.year)
	    @calendar.select_day(date.day)

	    @dialog.show_all
	    @dialog.move(@cal_pos[0], @cal_pos[1]) # Try again
	    @dialog.run
	end

	def on_button_press
	    if (not @month_changed)
		cd = @calendar.date
		date = Date.new(y=cd[0], m=cd[1], d=cd[2])

		# Update anyone who is interested in the new date
		signal_emit(DATE_UPDATE, date)

		@entry.text = date.to_s
		@dialog.vbox.remove(@calendar)
		@dialog.destroy

		# Re-create a new calendar
		@calendar = Gtk::Calendar.new
	    else
		@month_changed = false
	    end
	end

	def on_select(calendar, signal_name)
	    if signal_name == 'month-changed'
		@month_changed = true
	    else
		@month_changed = false
	    end
	end
    end


    ######################################################################
    # Work view
    ######################################################################
    class View

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

	    # Remove the old date widget
	    hbox = @builder.get_object('button_hbox')
	    hbox.remove(@builder.get_object('date'))
	    
	    widget = CalendarComboBoxEntry.new

	    # Adding the new dropdown calendar widget
	    hbox.add(widget)
	    hbox.reorder_child(widget, 1)
	    hbox.set_child_packing(widget, false, true, 0, Gtk::PACK_START)

	    # due to the builder not updating properly...
	    @date_widget = widget

	    # Date widget will want to update the controller's concept of date
	    @date_widget.signal_connect(CalendarComboBoxEntry::DATE_UPDATE) do |obj, date|
		@controller.date = date
	    end
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
		p filename
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
	    @date_widget.date = date
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
	    @controller.quit

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
	    about.copyright = "Copyright (c) 2009, 2010 Anja Berens"

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
	    @controller.file_regex.each do |regex|
		filter.add_pattern(regex)
	    end
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
	    @date_widget.clear
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
end
