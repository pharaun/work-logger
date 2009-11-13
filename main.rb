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

work_gui = Work_logger::new
work_gui.run
