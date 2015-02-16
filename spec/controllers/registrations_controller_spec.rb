require "rails_helper"

describe RegistrationsController do
  describe "#new" do
    it "loads a new user" do
      get :new
      expect(assigns(:user)).to be_new_record
    end
  end

  describe "#create" do
    let(:username) {  "username" }
    let(:password) {  "password" }
    let(:email) { "email@example.com" }

    context "when valid params are provided" do
      let(:mailer) { double(deliver_later: true) }

      before :each do
        allow(UserMailer).to receive(:registration_email).and_return(mailer)
        post :create, user: {
          username: username,
          password: password,
          email: email,
          terms_and_conditions: "1"
        }
      end

      it "creates a new user account" do
        expect(User.count).to eql(1)
        first_user = User.first
        expect(first_user.username).to eql(username)
        expect(first_user.email).to eql(email)
      end

      it "redirects them to the dashboard" do
        expect(response).to redirect_to(dashboard_path)
      end

      it "logs them in" do
        expect(session[:user_id]).to eql(User.first.id)
      end

      it "does not display any errors" do
        expect(flash[:error]).to be_nil
      end

      it "shows a flash alert" do
        expect(flash[:notice]).to_not be_empty
        expect(flash[:notice]).to eql("Thank you for registering. Welcome to Supply Crow.")
      end

      it "sends a user registration email" do
        expect(mailer).to have_received(:deliver_later)
      end
    end

    context "when the parameters provided are invalid" do
      before :each do
        post :create, user: {
          username: "",
          password: password,
          email: email,
          terms_and_conditions: "1"
        }
      end

      it "adds an error to the flash for missing usernames" do
        expect(flash[:error]).to_not be_nil
        expect(flash[:error]).to_not be_empty
      end

      it "does not log them in" do
        expect(session[:user_id]).to be_nil
      end

      it "renders the registration page" do
        expect(response).to render_template(:new)
      end
    end
  end
end
