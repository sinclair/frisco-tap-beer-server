require 'rubygems'
require 'bundler'

Bundler.require

require './beer_server'

run Sinatra::Application
