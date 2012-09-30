require_relative '../../Ad'

describe Ad do
  before(:each) do
    @ad = Ad.new
    @ad.street0 = '1 Sugar Bowl Dr'
    @ad.street1 = 'W Stadium Dr'
    @ad.city = 'New Orleans'
    @ad.state = 'LA'
  end

  it 'should format address as street, city, state' do
    @ad.address.should eq '1 Sugar Bowl Dr, New Orleans, LA'
  end

  it 'should format address as "street0 at street1, city, state" if there is no house number in street0' do
    @ad.street0 = 'Sugar Bowl Dr'

    @ad.address.should eq 'Sugar Bowl Dr at W Stadium Dr, New Orleans, LA'
  end

  it 'should format address as "street0 at street1, city, state" if street0 is a number street with no house number' do
    @ad.street0 = '1st St'

    @ad.address.should eq '1st St at W Stadium Dr, New Orleans, LA'
  end
end
