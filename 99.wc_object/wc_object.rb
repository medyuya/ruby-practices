#!/usr/bin/env ruby

# frozen_string_literal: true

require_relative 'lib_wc'

Wc.new(ARGV, ARGF).display
