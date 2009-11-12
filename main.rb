#!/usr/bin/env ruby
# Work logger
#
# Copyright (c) 2009, Anja Berens
#
# You can redistribute it and/or modify it under the terms of
# the GPL's licence.
#

require 'gtk2'


builder = Gtk::Builder.new
builder.add_from_file('view/main.glade')

window = builder.get_object('work_logger')
window.show_all

Gtk.main
