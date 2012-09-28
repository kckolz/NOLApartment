require 'feedzirra'
require 'nokogiri'
require 'open-uri'
require 'geocoder'
require_relative 'ad'
require_relative 'apartments'

class Loader
  def self.run
    feed = Feedzirra::Feed.fetch_and_parse('neworleans.craigslist.org/apa/index.rss')

    feed.entries.map do |entry|
      ad = Ad.new
      ad.parse(entry)
      ad.geocode!

      puts ad.to_json

      if ad.latitude && ad.longitude
        Apartments.add(ad.to_json)
      end
    end
  end
end

Loader.run

