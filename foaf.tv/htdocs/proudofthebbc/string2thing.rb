#!/usr/bin/env ruby -rubygems

require 'json'
require 'rdf' # http://rdf.rubyforge.org/

require 'rdf/ntriples'
require 'rdf/raptor'


# puts RDF::Raptor.available?         #=> true
# puts RDF::Raptor.version            #=> "1.4.21"

def getRDF(u)
  begin 
  g = RDF::Graph.load(u)
  puts "# Loading RDF: #{u} Size: #{u.size}"
  return g
  rescue
    puts "# Parsing barfed."
  end
end

$stdout.sync = true

# Takes a list of BBC-related things and gets some Wikipedia URLs
# Source list is from http://mitchbenn.com/

# curl -s -e http://danbri.org/  'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=bbc%20site:wikipedia.org'

wiki_qs = "curl -s -e http://danbri.org/  'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=zzzzz%20site:wikipedia.org'"
 bbc_qs = "curl -s -e http://danbri.org/  'http://ajax.googleapis.com/ajax/services/search/web?v=1.0&q=zzzzz%20site:www.bbc.co.uk/programmes/'"


# results: {"responseData": {"results":[{"GsearchResultClass":"GwebSearch","unescapedUrl": ...


dc = RDF::Vocabulary.new("http://purl.org/dc/elements/1.1/")
foaf = RDF::Vocabulary.new("http://xmlns.com/foaf/0.1/")

f=File.open('lyrics-list.txt').read
f.each do |item|
  item.chomp!
  next unless (item =~ /\w/) 
  next if (item =~ /^#/) 
  next if (item =~ /^\s\*/) 
  esc = item.gsub(/\s+/,'%20')
  esc.gsub!(/&/,'')
  esc.gsub!(/'/,'')

  puts "# #{item}"

  # Find Wikipedia links
  # Later we can find dbpedia.org links for metadata
  #
  wres = ` #{ wiki_qs.gsub(/zzzzz/, esc) } ` # umm


  wiki_feeling_lucky = JSON.parse(wres)['responseData']['results'][0]['unescapedUrl']
  wiki_feeling_lucky =~ /wikipedia\.org\/wiki\/(.*)/
  wid = $1
  w = "http://dbpedia.org/data/#{wid}.rdf"
  puts "# #{wid}\t#{  wiki_feeling_lucky}\t#{w}";

  g = getRDF(w)
  begin
    i = g.query( [nil, foaf.depicts, nil ]) do |img, p, res|
      puts "Image: #{img}"
    end
  rescue
    puts "# no rdf."
  end
  # Find BBC /programmes/ links
  # (later, we can append .rdf to get metadata)
  #
  bres =` #{ bbc_qs.gsub(/zzzzz/, esc) } ` 
  bbc_feeling_lucky = JSON.parse(bres)['responseData']['results'][0]['unescapedUrl']
  bbc_feeling_lucky =~ /bbc\.co\.uk\/programmes\/(.*)/
  bid = $1
  b = "http://www.bbc.co.uk/programmes/#{bid}.rdf"
  puts "Programmes:\t#{  bbc_feeling_lucky}\t#{b}";

  g= getRDF(b)
  begin
    i = g.query( [nil, foaf.depicts, nil ]) do |img, p, res|
      puts "Image: #{img}"
    end
  rescue
    puts "# no rdf."
  end
  
  puts   
  puts 
end


  # http://stackoverflow.com/questions/931548/the-state-of-rdf-in-ruby
