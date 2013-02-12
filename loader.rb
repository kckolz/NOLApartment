require 'feedzirra'
require './ad'
require './apartments'

# TODO make this a rake task
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

  def self.expire
    Apartments.collection.remove({:published => {'$lte' => Time.now - (7 * 24 * 60 * 60) }})
  end
end
