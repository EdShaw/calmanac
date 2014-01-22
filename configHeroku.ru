#!/usr/bin/env rackup
# encoding: utf-8

# This file can be used to start Padrino,
# just execute it from the command line.

require File.expand_path("../config/boot.rb", __FILE__)

#TraceView :3
require 'oboe'
require 'oboe/inst/rack'

# You may want to replace the Oboe.logger with your own
Oboe.logger = Padrino.logger

Oboe::Ruby.initialize
Padrino.use Oboe::Rack

run Padrino.application
