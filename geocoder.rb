require 'geocoder'
require 'open-uri'
require 'json'
require 'yaml'

module NOLApartment
  module Geocoder

    def self.google_key
      @@google_key ||= YAML::load(File.new('config/keys.yaml').read)[:google]
    end

    def self.get_location address, deep=true
      # Can't do 'deep' searches without a google api key.
      deep = deep && self.google_key != 'KEY'

      geocode_result = ::Geocoder.search(address).first
      result = {}

      if geocode_result
        bad_result = (geocode_result.types & %w(street_address intersection)).empty?

        result[:latitude] = geocode_result.latitude
        result[:longitude] = geocode_result.longitude

        if bad_result && deep
          # didn't get a good result. Google HALP!
          # TODO pull the google search out.
          response = open "https://www.googleapis.com/customsearch/v1?key=#{self.google_key}&cx=008774535076880730414:pil9ab_j8-e&q=#{URI::encode(address)}"
          search = JSON::parse response.read

          if spelling = search["spelling"]
            result = get_location spelling["correctedQuery"], false
          end
        end
      end

      result
    end
  end
end
