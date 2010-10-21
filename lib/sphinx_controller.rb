class SphinxController 
	include Singleton

	attr_reader :ruby_path, :xmlpipe_command, :index_file_folder, :searchd_port, :searchd_host, :searchd_log_path, :searchd_query_log_path, :searchd_pid_path, :sphinx_conf_path 

	def initialize
		b = binding
		sphinx_config = YAML.load(ERB.new(File.read(CONFIG_ROOT.join('sphinx.yml'))).result(b)) || {}
		@ruby_path = IO.popen('which ruby').first.strip
		@xmlpipe_command        = sphinx_config["xmlpipe_command"]        ||= "#{ruby_path} #{APP_ROOT.join('script/sos_index_source.rb')} #{DATA_ROOT.join('sos.json')}"
		@index_file_folder      = sphinx_config["index_file_folder"]      ||= APP_ROOT.join('sphinx/sos_core') #TODO
		@searchd_port           = sphinx_config["searchd_port"]           ||= 9312
		@searchd_host       = sphinx_config["searchd_host"]           ||= "localhost"
		@searchd_log_path       = sphinx_config["searchd_log_path"]       ||= APP_ROOT.join('log/searchd.log')
		@searchd_query_log_path = sphinx_config["searchd_query_log_path"] ||= APP_ROOT.join('log/searchd_query.log')
		@searchd_pid_path       = sphinx_config["searchd_pid_path"]       ||= APP_ROOT.join('log/searchd.pid')
		@sphinx_conf_path = CONFIG_ROOT.join('sphinx.conf')
	end

	def start 
		STDOUT.puts "starting sphinx searchd"
		exec("searchd --config #{self.sphinx_conf_path}")  
	end

	def stop 
		if File.exist? searchd_pid_path
			pid = File.read(searchd_pid_path)
			begin 
				Process.kill('SIGTERM', pid.to_i)
			rescue Errno::EINVAL
				Process.kill('SIGKILL', pid.to_i)
			end 
			STDOUT.puts "stoped sphinx searchd for pid #{pid}"
		else 
			STDERR.puts "can not find pid file in #{searchd_pid_path}"
		end
	end

	def build_index 
		STDOUT.puts "building index according to conf #{self.sphinx_conf_path}"
		exec("indexer --config #{self.sphinx_conf_path} --all")   
	end

	def generate_conf
		b = binding
		STDOUT.puts "generating conf file to #{self.sphinx_conf_path}"
		File.open(self.sphinx_conf_path,"w+") do |f|
			f.puts ERB.new(File.read(APP_ROOT.join('templates/sos_sphinx_conf.erb'))).result(b)
		end
	end

	def client 
		Riddle::Client.new(self.searchd_host, self.searchd_port) 
	end

end
