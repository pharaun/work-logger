#!/usr/bin/env ruby
# Work logger
#
# Copyright (c) 2009, Anja Berens
#
# You can redistribute it and/or modify it under the terms of
# the GPL's licence.
#

require 'gtk2'
require 'view'
require 'controller'

controller = Work::Controller.new
view = Work::View.new(controller)
controller.set_view(view)

view.show_all
Gtk.main
