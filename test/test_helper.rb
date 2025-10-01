# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter '/test/'
  add_filter '/vendor/'
end

require 'minitest/autorun'
require 'minitest/reporters'

# Use spec-style reporter for better output
Minitest::Reporters.use! [Minitest::Reporters::SpecReporter.new]

# Load the application code
require_relative '../lib/file_helpers'
require_relative '../lpx_links'

