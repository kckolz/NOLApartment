class Ad
  attr_accessor :street0, :street1, :city, :state, :latitude, :longitude, :beds,
    :price, :url, :title, :published

  def address
    if @street0
      street = @street0
      street += " at #{@street1}" unless /^\d+ / =~ @street0

      "#{street}, #{@city}, #{@state}"
    end
  end

  def geocode!
    if self.address
      result = Geocoder.search(self.address).first

      if result
        @latitude = result.latitude
        @longitude = result.longitude
      end
    end

    self
  end

  def parse(entry)
    @url = entry.url
    @title = entry.title
    @published = entry.published

    doc = Nokogiri::HTML(open(entry.url))
    doc.xpath('//comment()').each do |comment|
      case comment
      when /CLTAG xstreet0=(?<street0>.*)/
        @street0 = $~[:street0]
      when /CLTAG xstreet1=(?<street1>.*)/
        @street1 = $~[:street1]
      when /CLTAG city=(?<city>.*)/
        @city = $~[:city]
      when /CLTAG region=(?<region>.*)/
        @state = $~[:region]
      end
    end

    body = doc.css('.posting').text

    if body =~ /(?<beds>\d+)\s?(bed|br|bd)/i
      @beds = $~[:beds]
    end

    if body =~/\$(?<price>\d+(,\d*)?)/
      @price = $~[:price].gsub(',', '')
    end
  end

  def to_json
    {
      'url' => self.url,
      'title' => self.title,
      'published' => self.published,
      'beds' => self.beds,
      'price' => self.price,
      'latitude' => self.latitude,
      'longitude' => self.longitude
    }
  end
end

