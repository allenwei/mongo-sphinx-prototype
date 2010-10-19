require(File.join(File.dirname(__FILE__), 'boot'))

Dir.glob(File.join(APP_PATH,"tasks",'*.rake')).each do |task|
  require task
end


