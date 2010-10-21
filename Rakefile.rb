require 'rake'
app_path = File.expand_path("./", File.dirname(__FILE__))

task :default do 
  puts 'spacify rake task you want to execute'
end

task :enviroment do 
  require(File.join(app_path, 'boot'))
end

Dir.glob(File.join(app_path,"tasks",'*.rb')).each do |task|
  require task
end


