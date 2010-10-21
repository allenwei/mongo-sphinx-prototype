module MongoGriffin 
	class Search 
		include Enumerable

		attr_reader :controller,:client, :result, :query, :options, :array

		def initialize(query, options={})
			@controller = ::SphinxController.instance 
		 	@client = @controller.client	
			@query = query 
			@options = options
		end

		def populate
			return if @populated
			@populated = true
			prepare_client
			@results = client.query self.query, indexes
			@array = @results[:matches].map do |hash| 
			 	id = hash[:doc]	
				Sos.where(:id => id).limit(1).first 
			end
		end

		def to_a 
			populate
			@array
		end

		def prepare_client
			filters = [] 
			filters += extract_filters
			#filters += internal_filters
			client.filters = filters
		end

		def extract_filters
			return unless @options[:with] 
			fs = []
			@options[:with].each_pair do |key, value| 
				fs << Riddle::Client::Filter.new(key.to_s, filter_value(value))
			end
			fs
		end

    def filter_value(value)
      case value
      when Range
        filter_value(value.first).first..filter_value(value.last).first
      when Array
        value.collect { |v| filter_value(v) }.flatten
      when Time
        [value.to_i]
      when NilClass
        0
      else
        Array(value)
      end
    end
		



		def populated?
			!!@populated
		end

		def indexes 
			return "*" #TODO
		end

		#def internal_filters
			#filters << Riddle::Client::Filter.new('class_crc', class_crcs)
		#end
		#
		
		def each
			@array.each do |instance|
				yield instance
			end
		end


	end
end
