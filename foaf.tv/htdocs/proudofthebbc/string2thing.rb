#!/usr/bin/env ruby -rubygems

require 'json'

# Takes a list of BBC-related things and gets some Wikipedia URLs
# Source list is from http://mitchbenn.com/

# curl -s -e http://danbri.org/  'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=bbc%20site:wikipedia.org'

wiki_qs = "curl -s -e http://danbri.org/  'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=zzzzz%20site:wikipedia.org'"
 bbc_qs = "curl -s -e http://danbri.org/  'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=zzzzz%20site:www.bbc.co.uk/programmes/'"


# results: {"responseData": {"results":[{"GsearchResultClass":"GwebSearch","unescapedUrl": ...


f=File.open('lyrics-list.txt').read
f.each do |item|
  item.chomp!
  next unless (item =~ /\w/) 
  next if (item =~ /^#/) 
  next if (item =~ /^\s\*/) 
  esc = item.gsub(/\s+/,'%20')
  esc.gsub!(/&/,'')
  esc.gsub!(/'/,'')

  puts item

  # Find Wikipedia links
  # Later we can find dbpedia.org links for metadata
  #
  wres = ` #{ wiki_qs.gsub(/zzzzz/, esc) } ` # umm
  wiki_feeling_lucky = JSON.parse(wres)['responseData']['results'][0]['unescapedUrl']
  puts "#{  wiki_feeling_lucky}\t# Wiki";

  # Find BBC /programmes/ links
  # (later, we can append .rdf to get metadata)
  #
  bres =` #{ bbc_qs.gsub(/zzzzz/, esc) } ` 
  bbc_feeling_lucky = JSON.parse(bres)['responseData']['results'][0]['unescapedUrl']
  puts "Programmes:\t#{  bbc_feeling_lucky}\t# Wiki ";

  puts 
end
