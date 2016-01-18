#!/usr/bin/env ruby
require 'open-uri'
require 'csv'
require 'awesome_print'

LANG = {
		ar: 'العربية',
		bg: 'български език',
		de: 'Deutsch',
		en: 'English',
		es: 'Español',
		fa: 'فارسی',
		fi: 'Suomi',
		fr: 'Français',
		gr: 'Ελληνικά',
		il: 'עברית',
		it: 'Italiano',
		nl: 'Nederlands',
		no: 'Norsk',
		pl: 'Polski',
		pt: 'Português',
		ro: 'Română',
		ru: 'русский язык',
		tr: 'Türkçe',
		vn: 'Tiếng Việt'
}

csv     = CSV.new open 'https://framacalc.org/ssa_press.csv'
content = {}
lang    = nil
csv.each do |row|
	if not row[0].nil? and row[1].nil?
		lang          = row[0].downcase
		content[lang] = {} unless content.include? lang
	elsif not row[1].nil?
		date               = DateTime.parse row.first
		row[0]             = date
		day                = date.to_date
		content[lang][day] = [] unless content[lang].include? day
		content[lang][day] << row
	end
end

lines = []
content.sort do |a, b|
	count = Proc.new { |x| x.collect { |x| x.size }.inject :+ }
	a = count.call a
	b = count.call b
	b <=> a
end.each do |lang, days|
	lang = lang.to_sym
	lines << [
			#"= image_tag '#{lang}_big.png', alt: '#{lang.upcase}'",
			"%b\##{lang} #{LANG[lang.to_sym]}",
			'%ul'
	]

	days.keys.sort.reverse.each do |day|
		lines << [
				"\t%li",
				"\t\t#{day.strftime '%d/%m/%Y'}",
				"\t\t%ul"
		]

		days[day].sort do |a, b|
			a, b = a.first, b.first
			next 1 unless a
			next -1 unless b
			b <=> a
		end.each do |_, url, media, title|
			lines << [
					"\t\t\t%li",
					"\t\t\t\t#{media}",
					"\t\t\t\t%a{href: '#{url}'} #{title}"
			]
		end
	end
end
puts lines.join "\n"
