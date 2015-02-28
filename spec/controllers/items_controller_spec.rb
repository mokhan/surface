require "rails_helper"

RSpec.describe ItemsController, type: :controller do

  context "when logged in" do
    let(:user) { create(:user) }

    before :each do
      auth_user(user)
    end

    describe "#index" do
      let(:other_user) { create(:user) }
      let!(:my_item) { create(:item, user: user) }
      let!(:their_item) { create(:item, user: other_user) }

      it "loads all your items" do
        get :index
        expect(assigns(:items)).to match_array([my_item])
      end
    end

    describe "#show" do
      let(:item) { create(:item, user: user) }
      let(:other_user) { create(:user) }
      let(:other_guys_item) { create(:item, user: other_user) }

      it "loads your item" do
        get :show, id: item.id
        expect(assigns(:item)).to eql(item)
      end

      it 'does not load other peoples items' do
        get :show, id: other_guys_item.id
        expect(response.status).to eql(404)
      end
    end
  end
end
