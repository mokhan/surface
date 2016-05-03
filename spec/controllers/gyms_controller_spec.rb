require 'rails_helper'

describe GymsController do
  let(:user) { create(:user) }

  before :each do
    http_login(user)
  end

  describe "#index" do
    let(:sait) { create(:gym, name: 'sait') }
    let(:world_health) { create(:gym, name: 'world health') }

    it 'returns a list of gyms' do
      get :index

      expect(assigns(:gyms)).to match_array([sait, world_health])
      expect(response).to be_ok
    end
  end

  describe "#new" do
    it 'loads the new page' do
      get :new
      expect(response).to be_ok
      expect(assigns(:gym)).to be_instance_of(Gym)
      expect(assigns(:gym).location).to be_present
    end

    it 'loads the available countries' do
      get :new
      expect(assigns(:countries).count).to eql(248)
      expect(assigns(:countries)).to include(["Canada", "CA"])
    end
  end

  describe "#create" do
    context "valid params" do
      before :each do
        post :create, gym: {
          name: 'SAIT',
          location_attributes: {
            address: '1301 16 Ave NW',
            city: 'Calgary',
            region: 'AB',
            country: 'CA',
            postal_code: 'T2M 0L4',
          }
        }
      end

      it 'redirects to the listing page' do
        expect(response).to redirect_to(gyms_path)
      end

      it 'creates a new gym' do
        expect(Gym.count).to eql(1)
        gym = Gym.last
        expect(gym.name).to eql('SAIT')
        expect(gym.location).to be_present
        expect(gym.location.address).to eql('1301 16 Ave NW')
        expect(gym.location.city).to eql('Calgary')
        expect(gym.location.region).to eql('AB')
        expect(gym.location.country).to eql('CA')
        expect(gym.location.postal_code).to eql('T2M 0L4')
      end
    end

    context "invalid params" do
      before :each do
        post :create, gym: { name: '' }
      end

      it 'displays an error' do
        expect(flash[:error]).to eql(assigns(:gym).errors.full_messages)
      end

      it 'renders the form with the original values entered' do
        expect(response).to render_template(:new)
        expect(assigns(:gym)).to be_present
      end
    end
  end
end
