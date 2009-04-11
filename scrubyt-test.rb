require 'rubygems'
require "#{File.dirname(__FILE__)}/../scrubyt/lib/scrubyt.rb"

blog_url = "http://blog.platinumsolutions.com"

blog_data = Scrubyt::Extractor.define do
  fetch blog_url

  blog_entry '//div[@class="entry-head"]' do
		blog_url "//h2/a/@href", :format_output => lambda {|x| blog_url + x }
  	blog_title "//h2/a"
  	blog_author_id "//ul/li/a[@class='blog_usernames_blog']/@href", :format_output => lambda {|x| x.split('/')[2]}
  	blog_author "//ul/li/a[@class='blog_usernames_blog']", :format_output => lambda {|x| x.split('&')[0]}
  	blog_date "//span/abbr", :format_output => lambda {|x| x.split(' ')[1]}
  	number_of_reads "//span[@class='statistics_counter']", :format_output => lambda {|x| x.split(' ')[0]}
  end
  
	next_page "//a[@title='Go to next page']", :limit => 1
end

puts blog_data.to_xml
