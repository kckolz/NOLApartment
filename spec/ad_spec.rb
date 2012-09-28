require_relative '../Ad'

describe Ad do
  before(:each) do
    @ad = Ad.new
    @ad.street0 = '209 Pine St'
    @ad.street1 = 'Lake Ave'
    @ad.city = 'Metairie'
    @ad.state = 'LA'
  end

  it 'should format address as street, city, state' do
    @ad.address.should eq '209 Pine St, Metairie, LA'
  end

  it 'should format address as "street0 at street1, city, state" if there is no house number in street0' do
    @ad.street0 = 'Pine St'

    @ad.address.should eq 'Pine St at Lake Ave, Metairie, LA'
  end

  it 'should format address as "street0 at street1, city, state" if street0 is a number street with no house number' do
    @ad.street0 = '1st St'

    @ad.address.should eq '1st St at Lake Ave, Metairie, LA'
  end
end
