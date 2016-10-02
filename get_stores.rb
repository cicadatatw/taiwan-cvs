# encoding=utf-8 
require 'open-uri'
require 'json'

brands = ["7-11", "family", "hilife", "okmart"]

if ARGV[0].nil?
	puts "列出全台 7-11、全家、萊爾富、OK"
else
	if brands.include? ARGV[0]
		puts "列出全台 " + ARGV[0]
		brands = []
		brands << ARGV[0]
	else
		raise "找不到 " + ARGV[0] + "，試試 7-11 或 family 或 hilife 或 okmart"
	end
end


unless Dir.exists?("data")
	Dir.mkdir("data")
end

for brand in brands

	top_url = "http://www.319papago.idv.tw/lifeinfo/#{brand}/#{brand}-00.html"
	top_path = "http://www.319papago.idv.tw/lifeinfo/#{brand}/"
	tmp = open(top_url)
	page = tmp.read

	pat1 = /(#{brand}-\d{2}.html)/
	pat2 = /(#{brand}-\d{3}.html)/
	pat3 = /<td height="33">(\d+)<\/td>\s+<td height="33">(\S+)<\/td>\s+<td height="33">(\(?\d+[\)-]\d+)[\u{00A0}\s]?<\/td>\s+<td height="33">(\S+)<\/td>/u
	pat4 = /<td height="33">(\S+)<\/td>\s+<td height="33">(\(?\d+[\)-]\d+)[\u{00A0}\s]?<\/td>\s+<td height="33">(\S+)<\/td>/u
	
	counties = page.scan(pat1).to_a

	data = []

	for county in counties
		county_url = top_path + county[0].to_s
		puts "visiting " + county_url
		tmp = open(county_url)
		page = tmp.read
		distrits = page.scan(pat2).to_a
		for district in distrits
			district_url = top_path + district[0].to_s
			puts "visiting " + district_url
			tmp = open(district_url)
			page = tmp.read.force_encoding("utf-8")
			case brand
				when "7-11" 
					stores = page.scan(pat3).to_a
				when "family"
					stores = page.scan(pat3).to_a
				when "hilife"
					stores = page.scan(pat4).to_a
				when "okmart"
					stores = page.scan(pat4).to_a
			end 
			data << stores
			puts stores
		end

	end


	File.open("data/#{brand}.json", "w+:utf-8") do |i|
	    i.write(JSON.pretty_generate(data))
	end

end
