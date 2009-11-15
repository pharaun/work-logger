#!/usr/bin/env ruby
# Work logger
#
# Copyright (c) 2009, Anja Berens
#
# You can redistribute it and/or modify it under the terms of
# the GPL's licence.
#

require 'gtk2'
require 'work-logger'
require 'sqlite'

sqlite = Sqlite::new
work_gui = Work_logger::new(sqlite)
work_gui.run
