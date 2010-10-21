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
			@result = client.query self.query, indexes
			@array = @result[:matches].map do |hash| 
			 	id = hash[:doc]	
				Sos.where(:id => id).limit(1).first 
			end
		end

		def to_a 
			populate
			@array
		end

		def result 
			populate
			@result
		end

		def prepare_client
			filters = [] 
			filters += extract_filters
			#filters += internal_filters
			client.filters = filters
			client.group_by = group_by 
			client.group_function = :attr
			client.match_mode = match_mode
		end

		def group_by 
			@options[:group].to_s
		end

		def extract_filters
			return [] unless @options[:with] 
			fs = []
			@options[:with].each_pair do |key, value| 
				fs << Riddle::Client::Filter.new(key.to_s, filter_value(value))
			end
			fs
		end

		def query
			@query + conditions_as_query
		end

		def each_with_groupby_and_count 
			result[:matches].each_with_index do |match, index| 
				yield match[:attributes]["@groupby"], match[:attributes]["@count"]
			end
		end

		def match_mode
			@options[:match_mode] || (@options[:conditions].blank? ? :all : :extended)
		end
		

		def conditions_as_query
			return '' if @options[:conditions].blank?
			keys = @options[:conditions].keys
			' ' + keys.collect { |key|
				"@#{key} #{options[:conditions][key]}"
			}.join(' ')
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
