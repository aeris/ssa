#!/usr/bin/env ruby
require 'open-uri'
require 'csv'
csv = CSV.new open 'https://framacalc.org/ssa_press.csv'
content = {}
lang = nil
csv.each do |row|
	if not row[0].nil? and row[1].nil?
		lang = row[0].downcase
		content[lang] = [] unless content.include? lang
	elsif not row[1].nil?
		date = row.first
		date = DateTime.parse date if date
		row[0] = date
		content[lang] << row
	end
end
content = content.map do |lang, articles|
	articles.sort! do |a, b|
		a, b = a.first, b.first
		next 1 unless a
		next -1 unless b
		a <=> b
	end
	[lang, articles]
end.to_h
lines = []
content.each do |lang, articles|
	lines << "= image_tag '#{lang}_big.png', alt: '#{lang.upcase}'"
	lines << '%ul'
	articles.each do |date, url, media, title|
		lines << [
			"\t%li",
			"\t\t#{date ? "(#{date.strftime '%d/%m/%Y'}) " : ''}#{media}",
			"\t\t%a{href: '#{url}'} #{title}"
		]
	end
end
puts lines.join "\n"
