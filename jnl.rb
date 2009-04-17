require 'rubygems'
require 'scrubyt'

jnl_url = "http://www.justnewlistings.com"

property_data = Scrubyt::Extractor.define :agent => :firefox do
  fetch jnl_url
  
  fill_textfield 'ma-name', '***'
  fill_textfield 'ma-email', '***'
  submit
  
end
  
puts property_data.to_xml
