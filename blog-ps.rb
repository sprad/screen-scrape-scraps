require 'rubygems'
require 'scrubyt'
require 'date'

class BlogEntry
  attr_accessor :url, :title, :date, :num_of_reads
  
  def initialize(blog_hash)
    @url = blog_hash[:url]
    @title = blog_hash[:blog_title]
    @date = Date.parse(blog_hash[:blog_date])
    @num_of_reads = blog_hash[:number_of_reads].to_i
  end 
end
 
class BlogEntryAuthor
  attr_accessor :id, :name, :entries
 
  def initialize(blog_hash)
    @id = blog_hash[:blog_author_id]
    @name = blog_hash[:blog_author]
    @entries = []
  end
 
  def num_of_entries
    @entries.size
  end
 
  def total_reads
    @entries.inject(0){|sum,item| sum + item.num_of_reads}
  end
 
  def reads_per_entry
    total_reads / num_of_entries
  end
end

blog_url = "http://blog.platinumsolutions.com"

blog_data = Scrubyt::Extractor.define do
  fetch blog_url

  blog_entry '//div[@class="entry-head"]' do
  	blog_title "//h2/a"
		blog_url "//h2/a/@href", :format_output => lambda {|x| blog_url + x }
  	blog_date "//span/abbr", :format_output => lambda {|x| x.split(' ')[1]}
  	blog_author "//ul/li/a[@class='blog_usernames_blog']", :format_output => lambda {|x| x.split('&')[0]}
  	blog_author_id "//ul/li/a[@class='blog_usernames_blog']/@href", :format_output => lambda {|x| x.split('/')[2]}
  	number_of_reads "//span[@class='statistics_counter']", :format_output => lambda {|x| x.split(' ')[0]}
  end
  
	next_page "//a[@title='Go to next page']" #, :limit => 1
end

blog_entries = {}

blog_data.to_hash.each do |bh|
    next unless bh[:blog_author_id] #move on if there is no author 		
 	  blog_entries[bh[:blog_author_id]] = BlogEntryAuthor.new(bh) unless blog_entries[bh[:blog_author_id]]
    blog_entries[bh[:blog_author_id]].entries << BlogEntry.new(bh)
end

be_sorted_by_total = blog_entries.sort{|a,b| b[1].num_of_entries <=> a[1].num_of_entries}
#be_sorted_by_rpe = blog_entries.sort{|a,b| b[1].reads_per_entry <=> a[1].reads_per_entry}

be_sorted_by_total.each { |k, author|
	puts "#{author.name}: #{author.num_of_entries}|#{author.total_reads}|#{author.reads_per_entry}"
}
