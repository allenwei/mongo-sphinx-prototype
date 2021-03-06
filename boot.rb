require 'rubygems'
require 'bundler'

require 'mongoid'
require 'riddle'
require 'ruby-debug'
Bundler.setup

APP_ROOT = Pathname.new(File.expand_path(File.dirname(__FILE__)))
DATA_ROOT = APP_ROOT.join("data")
CONFIG_ROOT = APP_ROOT.join("config")
MODEL_ROOT = APP_ROOT.join("models")

Dir.glob(File.join(APP_ROOT,"models",'*.rb')).each do |model|
  require model
end

Dir.glob(File.join(APP_ROOT,"lib",'*.rb')).each do |lib|
  require lib
end

Mongoid.configure do |config|
  name = "mongo_griffin"
  host = "localhost"
  config.master = Mongo::Connection.new.db(name)
  #config.slaves = [
    #Mongo::Connection.new(host, 27018, :slave_ok => true).db(name)
  #]
  config.persist_in_safe_mode = false
end



