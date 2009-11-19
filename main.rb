#!/usr/bin/env ruby
# Work logger
#
# Copyright (c) 2009, Anja Berens
#
# You can redistribute it and/or modify it under the terms of
# the GPL's licence.
#

require 'gtk2'
require 'work_view'
require 'work_controller'
require 'sqlite'

sqlite = Sqlite::new
controller = Work_controller::new(sqlite)
view = Work_view::new(controller)
controller.set_view(view)

view.show_all
Gtk.main
