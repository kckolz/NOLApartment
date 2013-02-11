require 'geocoder'
require './spell_checker'

module NOLApartment
  module Geocoder
    def self.spell_checker
      @@spell_checker ||= SpellChecker.new
    end

    def self.good_response? response
      ( %w(street_address intersection) & response.types ).any?
    end

    def self.parse_response response
      {
        :latitude => response.latitude,
        :longitude => response.longitude
      }
    end

    def self.get_location address, deep=true
      geocode_result = ::Geocoder.search(address).first

      result = if self.good_response? geocode_result
        self.parse_response(geocode_result)
      elsif deep && corrected_address = self.spell_checker.check(address)
        self.get_location(corrected_address, false)
      end

      result || {}
    end
  end
end
