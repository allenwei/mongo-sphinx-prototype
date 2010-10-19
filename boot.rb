require 'rubygems'
require 'bundler'

require 'mongoid'
require 'riddle'

Bundler.setup

APP_PATH = File.expand_path(File.dirname(__FILE__))

Dir.glob(File.join(APP_PATH,"models",'*.rb')).each do |model|
  require model
end

Dir.glob(File.join(APP_PATH,"lib",'*.rb')).each do |lib|
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



