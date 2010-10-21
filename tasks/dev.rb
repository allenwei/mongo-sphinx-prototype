namespace :sphinx do

  desc "build index according to json" 
  task :build => :enviroment do 
    SphinxController.instance.generate_conf 
    SphinxController.instance.build_index
  end

  desc "start searchd" 
  task :start => :enviroment do 
    SphinxController.instance.start
  end

  desc "stop searchd" 
  task :stop => :enviroment do 
    SphinxController.instance.stop
  end

  desc "rebuild" 
  task "rebuild" => :enviroment do 
    SphinxController.instance.stop
    SphinxController.instance.generate_conf 
    SphinxController.instance.build_index
    SphinxController.instance.start
  end

  desc "restart"
  task "restart" => :enviroment do 
    SphinxController.instance.stop
    SphinxController.instance.start
  end
end

namespace :dev do
  desc "import test data to mongodb" 
  task :import => :enviroment do 
    db_name = Mongoid.database.name
    host, port = Mongoid.database.connection.primary 
    Dir.glob(DATA_ROOT.join("*.json")).each do |file_path|
      path = Pathname.new(file_path)
      collection_name = path.basename(".json")

      STDOUT.puts "clean collection #{collection_name} ..."
      Mongoid.database.drop_collection(collection_name)

      STDOUT.puts "import file #{path} into collection #{collection_name} ..."
      system("mongoimport -h #{host}:#{port} -d #{db_name} -c #{collection_name} --file #{path}")
      STDOUT.puts "finish import file #{path} into collection #{collection_name}"
    end
  end
end

