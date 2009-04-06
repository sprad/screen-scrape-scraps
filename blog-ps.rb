require 'date'
require 'open-uri'
require 'rubygems'
require 'builder'
require 'hpricot'

blog_entries = {}
url = 'http://blog.platinumsolutions.com'
parsing_path = '/'

class BlogEntry
	attr_accessor :id, :title, :date, :num_of_reads
end

class BlogEntryAuthor
	attr_accessor :id, :name, :entries

	def initialize(id, name)
		@id = id
		@name = name
		@entries = []
	end

	def num_of_entries
		@entries.size
	end

	def total_reads
		@entries.inject(0){|sum,item| sum + item.num_of_reads.to_i}
	end

	def reads_per_entry
		total_reads / num_of_entries
	end
end

parse_entries = Proc.new do |html, year|
	#puts "parsing page: #{url + parsing_path}"

	html.search("div.entry-head").each do |header|
		entry_html = Hpricot(header.inner_html)
		next unless entry_html.at('abbr') #move on if there is no author

		be_date = Date.parse(entry_html.at('abbr').inner_html.split(' ')[1])

		if (!year || be_date > Date.new(y=year.to_i) && be_date < Date.new(y=year.to_i+1))			
			be = BlogEntry.new
			be.id = entry_html.at('a')['href'].split('/')[2]
			be.title = entry_html.at('a').inner_html
			be.date = be_date
			be.num_of_reads = entry_html.at("span.statistics_counter").inner_html.split(' ')[0]
			author_id = entry_html.at('li.blog_usernames_blog/a')['href'].split('/')[2]
			author_name = entry_html.at('li.blog_usernames_blog/a').inner_html.split('&')[0]        

			blog_entries[author_id] = BlogEntryAuthor.new(author_id, author_name) unless blog_entries[author_id]
			blog_entries[author_id].entries << be
		end
  end
end

def find_path(html)    
	path = nil
	html.search('div.pager/a').each do |link|
		  path = link['href'] if link['title'] == 'Go to next page'
	end	
	path
end

while parsing_path
	doc = open("#{url + parsing_path}") { |f| Hpricot(f) }        
	parse_entries.call(doc, ARGV[0])
	parsing_path = find_path(doc)
end

be_sorted_by_rpe = blog_entries.sort{|a,b| b[1].reads_per_entry <=> a[1].reads_per_entry}
be_sorted_by_total = blog_entries.sort{|a,b| b[1].num_of_entries <=> a[1].num_of_entries}

xml = Builder::XmlMarkup.new( :target => $stdout, :indent => 2 )

xml.table do 
	xml.tr do
		xml.th('Name')
		xml.th('Reads/Entry')
		xml.th('Total Reads')
		xml.th('Number of Entries')						
	end

	be_sorted_by_rpe.each do | k, v |
		xml.tr do 
			xml.td(v.name) 
		  xml.td(v.reads_per_entry) 
		  xml.td(v.total_reads)
		  xml.td(v.num_of_entries)
		end
	end
end
