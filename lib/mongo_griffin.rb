module MongoGriffin
	def self.search(keyword, options={})
		Search.new(keyword, options)
	end
end

Dir.glob(File.join(File.dirname(__FILE__),'mongo_griffin','*.rb')).each do |f| 
	require f
end
