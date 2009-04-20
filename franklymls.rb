require 'rubygems'
require 'scrubyt'
require 'builder'

class Property
	attr_accessor :mls, :list_price, :dom, :address, :city, :zip, :bed, :bath, :sqft, :built

	def initialize(property)
		@mls = (property/:mls).inner_html
		@list_price = (property/:list_price).inner_html
		@dom = (property/:dom).inner_html
		@address = (property/:address).inner_html
		@city = (property/:city).inner_html
		@zip = (property/:zip).inner_html
		@bed = (property/:bed).inner_html
		@bath = (property/:bath).inner_html
		@sqft = (property/:sqft).inner_html
		@built = (property/:built).inner_html
	end
end

zips = [22201,22202,22203,22209]
beds = [2, 3].collect{ |bed| bed.to_s+'bdr'}
min_price = 150 #in thousands
max_price = 350 #in thousands
exclusions = ['JEFFERSON'].collect{ |exclude| "+-#{exclude}"}

fmls_url = "http://franklymls.com/default.aspx?m=R&l=#{min_price}K&h=#{max_price}K"
fmls_url += "&s=(#{zips.join(',')})+active"
fmls_url += "+(#{beds.join(',')})"
fmls_url += exclusions.to_s

property_data = Scrubyt::Extractor.define do
  fetch fmls_url

  properties '//table[@id="dgRealtorStyle"]' do
  	property "//tr" do
			mls "/td[1]//a[2]"
			list_price "/td[2]"
			dom "/td[7]"
			address "/td[8]"
			city "/td[9]"
			zip "/td[10]"
			bed "/td[13]", :format_output => lambda {|bed_bath| bed_bath.split('/')[0]}
			bath "/td[13]", :format_output => lambda {|bed_bath| bed_bath.split('/')[1]}
			sqft "/td[14]"
			built "/td[15]"			
		end
  end  
end

property_hash = {}

hp = Hpricot.XML(property_data.to_xml)
(hp/:property).each do |property|
   property_hash[(property/:mls).inner_html] = Property.new(property)
end

xml = Builder::XmlMarkup.new(:target => $stdout, :indent => 2 )
xml.instruct! :xml, :version => "1.0"
xml.rss :version => "2.0" do
	xml.channel do
		xml.title "Sprad's Property Feed"
		xml.link "http://www.sprad.net/propertyfeed.xml"
		xml.description "This is my property feed"

		property_hash.each do | key, property |
			pub_date = (Time.now - property.dom.to_i*60*60*24)
			pub_date = pub_date.strftime("%a, %d %b %Y %I:%M:%S")
			
		
			xml.item do 
				xml.title property.address
				xml.link "http://franklymls.com/#{property.mls}"
				xml.pubDate "#{pub_date} EST"
				xml.description "City: #{property.city}
					Address: #{property.address}
					Price: #{property.list_price}
					Bed: #{property.bed}
					Bath: #{property.bath}
		 		  Sqft: #{property.sqft}
		 		  Built: #{property.built}"
		 	end
		end
	end
end
