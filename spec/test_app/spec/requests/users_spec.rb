require 'rails_helper'

RSpec.describe "Users" do
  describe "GET /users" do
    it "works! (now write some real specs)" do
      # Run the generator again with the --webrat flag if you want to use webrat methods/matchers
      get users_path
      expect(response.status).to be(200)
    end
  end
end
