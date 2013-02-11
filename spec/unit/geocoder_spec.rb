require './geocoder'

describe NOLApartment::Geocoder do
  context 'get_location' do
    it 'should call geocoder search with the address' do
      address = '123 somewhere street'
      ::Geocoder.should_receive(:search, address) do
        NOLApartment::Geocoder.get_location address
      end
    end
  end

  context 'good_response?' do
    it 'should respond to good_response?' do
      NOLApartment::Geocoder.should respond_to :good_response?
    end

    it 'should return true if street_address is a type' do
      response = ::Geocoder::Result::Google.new({ 'types' => %w(street_address) })

      NOLApartment::Geocoder.good_response?(response).should eq true
    end

    it 'should return true if intersection is a type' do
      response = ::Geocoder::Result::Google.new({ 'types' => %w(intersection) })

      NOLApartment::Geocoder.good_response?(response).should eq true
    end

    it 'should return false for any other type' do
      response = ::Geocoder::Result::Google.new({ 'types' => %w(locality) })

      NOLApartment::Geocoder.good_response?(response).should eq false
    end
  end

  context 'parse_response' do
    it 'should return the lat/long pair for a good response' do
      response = ::Geocoder::Result::Google.new({ 'geometry' => { 'location' => {'lat' => 1, 'lng' => 2 }}})

      NOLApartment::Geocoder.parse_response(response).should eq({ :latitude => 1, :longitude => 2})
    end
  end
end
