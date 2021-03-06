require "rails_helper"

describe Location do
  describe ".from" do
    it "returns the correct lat/long" do
      VCR.use_cassette("geo-location-from-address") do
        latitude, longitude = Location.
          from("1301 16 Ave NW", "Calgary", "AB", "Canada")

        expect(latitude).to be_within(0.1).of(51.0647815)
        expect(longitude).to be_within(0.1).of(-114.0927691)
      end
    end
  end

  describe "#before_save" do
    let(:latitude) { rand(90.0) }
    let(:longitude) { rand(180.0) }

    it "assigns a lat/long" do
      allow(Location).to receive(:from).and_return([latitude, longitude])

      location = Location.new(
        address: "123 street sw",
        city: "edmonton",
        region: "alberta",
        country: "canada",
      )
      location.save!

      expect(location.latitude).to eql(latitude)
      expect(location.longitude).to eql(longitude)
    end
  end

  describe ".build_from_ip" do
    it "returns a location from the ip address" do
      VCR.use_cassette("geo-location-70.173.137.232") do
        result = Location.build_from_ip("70.173.137.232")
        expect(result).to be_instance_of(Location)
        expect(result.address).to include("Las Vegas")
        expect(result.city).to eql("Las Vegas")
        expect(result.region).to eql("NV")
        expect(result.country).to eql("US")
        expect(result.postal_code).to start_with("8910")
        expect(result.latitude).to be_within(0.2).of(36.1)
        expect(result.longitude).to be_within(0.2).of(-115.1)
      end
    end

    it "returns a location from the ip address" do
      VCR.use_cassette("geo-location-127.0.0.1") do
        result = Location.build_from_ip("127.0.0.1")
        expect(result).to be_instance_of(Location)
      end
    end
  end

  describe "#coordinates" do
    it "returns the lat/long" do
      subject.latitude = rand(90.0)
      subject.longitude = rand(180.0)
      expect(subject.coordinates).to match_array([
        subject.latitude,
        subject.longitude
      ])
    end

    it "returns an empty array" do
      VCR.use_cassette("geo-location-build_from_ip.172.18.0.1") do
        subject = Location.build_from_ip("172.18.0.1")
        expect(subject.coordinates).to be_empty
      end
    end
  end
end
