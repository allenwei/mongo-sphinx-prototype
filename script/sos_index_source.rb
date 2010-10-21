#!/usr/bin/ruby

# © Copyright 2010 jingmi. All Rights Reserved.
#
# +-----------------------------------------------------------------------+
# | Convert SOS json data file to XML for Sphinx                          |
# +-----------------------------------------------------------------------+
# | Author: jingmi@seravia.com                                            |
# +-----------------------------------------------------------------------+
# | Created: 2010-10-15 14:51                                             |
# +-----------------------------------------------------------------------+

require 'json'
require 'logger'
require 'zlib'


def new_logger filename = nil
  return Logger.new('log.txt') unless filename
  Logger.new(filename)
end

def die message
  stderr = IO.new(2, "w")
  stderr.puts message
  $logger.error message
  exit -1
end

def init_logger filename = nil
  $logger = new_logger filename
end

def print_header
  print "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<sphinx:docset>\n"
end

def print_footer
  print "</sphinx:docset>\n"
end

def convert_to_xml json_var
  xml_doc = '  <sphinx:document id="' + json_var['id'].to_s + '">' + "\n"
  xml_doc += "    <name><![CDATA[[#{json_var['name']}]]></name>\n"
  xml_doc += "    <doc_id>#{json_var['id'].to_s}</doc_id>\n"
  xml_doc += "    <region_id>#{json_var['region_id']}</region_id>\n"
  xml_doc += "    <active>#{json_var['active']}</active>\n"
  xml_doc += "    <class_crc>#{Zlib.crc32("sos")}</class_crc>\n"
  xml_doc += "    <filing_date>#{json_var['filing_date']}</filing_date>\n"
  xml_doc += "  </sphinx:document>\n"

  xml_doc
end

def print_xml filename
  print_header
  lineno = 0
  IO.foreach(ARGV[0]) { |line|
    lineno += 1

    begin
      obj = JSON.parse(line)
    rescue => e
      $logger.error("#{lineno} error:" + e.to_s)
      next
    end
    unless (obj['names'].class.to_s == 'Array')
      $logger.error("[#{lineno}] `names' item is not an array")
      next
    end
    record = {}
    record['name'] = ''
    obj['names'].each { |name|
      record['name'] += name.to_s + " "
    }
    unless obj["id"]
      $logger.error("[#{lineno} no id exists!")
      next
    end
    record['id'] = obj['id'].to_s
    if obj['active'] 
      record['active'] = obj['active'].to_s
    else 
      record['active'] = "2"
    end
    record['region_id'] = obj['sos_state_id'].to_s
    if obj['formation_date']
      record['filing_date'] = Time.parse(obj['formation_date']).to_i
    else
      record['filing_date'] = 0
    end
    print convert_to_xml(record)
  }
  print_footer
end

init_logger
die "arg error" if (ARGV.size != 1)
die "cannot open file: #{ARGV[0]}" unless File.exists?(ARGV[0])
print_xml(ARGV[0])

=begin
------- Sphinx Config File Template -------
source xml_src
{
    type = xmlpipe2
    xmlpipe_command = /Users/jingmi/work/sphinx/sos_index_source.rb ~/platform/t-1000/sos.json
    xmlpipe_field = name
    xmlpipe_attr_uint = region_id
    xmlpipe_attr_uint = class_crc
    xmlpipe_attr_uint = active
    xmlpipe_attr_timestamp = filing_date
}

index xml_index
{
    source					= xml_src
    path					= /Users/jingmi/work/sphinx/var/data/xml
    docinfo					= extern
    charset_type			= utf-8
    morphology		= none
    min_word_len		= 2
}

indexer
{
    mem_limit				= 32M
}

searchd
{
    port					= 9312
    log						= /Users/jingmi/work/sphinx/var/log/searchd.log
    query_log				= /Users/jingmi/work/sphinx/var/log/query.log
    read_timeout			= 5
    max_children			= 30
    pid_file				= /Users/jingmi/work/sphinx/var/log/searchd.pid
    max_matches				= 1000
    seamless_rotate			= 1
    preopen_indexes			= 0
    unlink_old				= 1
}
=end

__END__
# vim: set expandtab tabstop=2 shiftwidth=2 foldmethod=marker:
