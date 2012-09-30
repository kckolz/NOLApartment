require_relative '../../geocoder'

describe NOLApartment::Geocoder do
  it 'should return and empty hash with no address' do
    result = NOLApartment::Geocoder.get_location ''

    result.should eq({})
  end

  it 'should return lat/long for a good street address' do
    result = NOLApartment::Geocoder.get_location '643 Magazine St, New Orleans, LA'

    result[:latitude].should eq 29.947093
    result[:longitude].should eq -90.069164
  end

  it 'should return lat/long for a street intersection address' do
    result = NOLApartment::Geocoder.get_location 'Magazine St at Girod St, New Olreans, LA'

    result[:latitude].should eq 29.9467949
    result[:longitude].should eq -90.06878379999999
  end

  it 'should return lat/long for a misspelled street' do
    result = NOLApartment::Geocoder.get_location '1615 n villeree st, New Orleans, LA'

    result[:latitude].should eq 29.9711559
    result[:longitude].should eq -90.0642421
  end
end
