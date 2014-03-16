require "hpricot"
require "open-uri"

class Rubygem
	attr_accessor :name
	attr_accessor :version
	attr_accessor :total_downloads
	attr_accessor :for_this_version
	attr_accessor :authors

	def initialize(name)
		stats = Rubygem.scrape(Rubygem.uri(name))
		@name = name
		@version = stats[:version]
		@total_downloads = stats[:total_downloads]
		@for_this_version = stats[:for_this_version]
		@authors = stats[:authors]
	end

	def self.uri(name)
		"http://rubygems.org/gems/#{name}"
	end

	def self.scrape(uri)
		doc = open(uri){|f|Hpricot(f)}
		g = self.gem_name(uri)
		v = self.version(doc)
		td = self.total_downloads(doc)
		ftv = self.for_this_version(doc)
		a = self.authors(doc)
		{:gem_name => g, :version => v, :total_downloads => td, :for_this_version => ftv, :authors => a}
	end

	def self.gem_name(uri)
		uri.scan(/\/gems\/\w+/).first.split("/")[-1]
	end

	def self.version(doc)
		doc.search("//div[@class='versions']").search("//a").first.attributes["href"].split("/")[-1]
	end

	def self.total_downloads(doc)
		doc.search("//div[@class='downloads counter']").search("//strong").first.inner_html.gsub(",","").to_i
	end

	def self.for_this_version(doc)
		doc.search("//div[@class='downloads counter']").search("//strong")[1].inner_html.gsub(",","").to_i
	end

	def self.authors(doc)
		doc.search("//div[@class='authors info-item']").search("//p").inner_html.split(", ")
	end
end
