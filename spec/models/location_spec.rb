require 'rails_helper'

describe Location do
  describe '.from' do
    it 'returns the correct lat/long' do
      latitude, longitude = Location.
        from('1301 16 Ave NW', 'Calgary', 'AB', 'Canada')

      expect(latitude).to be_within(0.1).of(51.0647815)
      expect(longitude).to be_within(0.1).of(-114.0927691)
    end
  end

  describe "#before_save" do
    let(:latitude) { rand(90.0) }
    let(:longitude) { rand(180.0) }

    it 'assigns a lat/long' do
      allow(Location).to receive(:from).and_return([latitude, longitude])

      location = Location.new(
        address: '123 street sw',
        city: 'edmonton',
        region: 'alberta',
        country: 'canada',
      )
      location.save!

      expect(location.latitude).to eql(latitude)
      expect(location.longitude).to eql(longitude)
    end
  end
end
