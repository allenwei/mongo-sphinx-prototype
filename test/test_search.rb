require File.expand_path('../boot.rb',File.dirname(__FILE__))

require "test/unit"

class SearchTest < Test::Unit::TestCase
	def test_simple_query 
		log 'MongoGriffin.search("inc")'
		result = MongoGriffin.search("inc")
		log_result(result)
	end	

	def test_query_with_fields
		log 'MongoGriffin.search("inc",:conditions => {:name => "smr"})'
		result = MongoGriffin.search("inc",:conditions => {:name => "smr"})
		log_result(result)
	end	

		def test_query_with_filters
		log 'MongoGriffin.search("inc",:with => {:region_id => [13]})'
		result = MongoGriffin.search("inc",:with => {:region_id => [13]})
		log_result(result)
	end	

		def test_query_group_by
			log 'MongoGriffin.search("inc",:group => :region_id)'
			result = MongoGriffin.search("inc",:group => :region_id)
			log_group_by_result(result)
		end	

	private 
	def log(str)
		puts ""
		puts "*"*80 
		puts "Testing " + str
		puts "*"*80  
	end

	def log_result(result) 
		puts result.to_a.map(&:names).inspect
	end

	def log_group_by_result(result) 
		puts "group_name          count"
		result.each_with_groupby_and_count do |group_name, count|	 
			puts "#{group_name}          #{count}"
		end
	end
	
end
