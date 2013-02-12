require 'json'
require 'open-uri'

class SpellChecker
  attr_reader :api_key

  def initialize api_key=nil
    @api_key = api_key || ENV['GOOGLE_API']
  end

  def check query
    if @api_key
      response = open(self.build_url(query))

      self.parse_response response.read
    end
  end

  def build_url query
    "https://www.googleapis.com/customsearch/v1?key=#{@api_key}&cx=008774535076880730414:pil9ab_j8-e&q=#{URI::encode(query)}"
  end

  def parse_response response
    json = JSON.parse response

    if spelling = json['spelling']
      spelling['correctedQuery']
    end
  end
end
