require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "switch_gear_sidekiq/middleware"
require 'sidekiq'
