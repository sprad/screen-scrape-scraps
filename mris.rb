require 'rubygems'
require 'scrubyt'

property_data = Scrubyt::Extractor.define :agent => :firefox do
  fetch '<YOUR MRIS.COM URL>'

  property "html/body/form" do
  	property_id "//td[@colspan='3']/b[1]"   	
  	property_address "//td[@class='d42764m20']//span[@class='d42764m21']"
  	mls "//td[@class='d42764m15']//span[@class='d42764m18']"  	
  	bed "//td[@class='d42764m42']//span[@class='d42764m43']"  	  	  	
  	full_bath "//td[@class='d42764m42']//span[@class='d42764m9'][2]"
  	half_bath "//td[@class='d42764m42']//span[@class='d42764m9'][3]"  	
  	list_price "//td[@class='d42764m26']//span[@class='d42764m27']"  	
  	square_feet "//td[@class='d42764m65']//span[@class='d42764m9']"    
  	hoa_fee "//div[3]/div/div/table/tbody/tr/td/table/tbody//tr[2]/td/table/tbody//tr[17]//td[3]//span[2]"
  	coa_fee "//div[3]/div/div/table/tbody/tr/td/table/tbody//tr[2]/td/table/tbody//tr[18]//td[3]//span[2]"
  end

  next_page 'Next'
end

property_file = File.new("properties.xml", "w")
property_file.write(property_data.to_xml)
property_file.close