require 'rails_helper'

RSpec.describe "admin create plant" do

  context "admin logged in" do

    let(:user) { create(:user, :admin) }

    before do
      visit login_path
      fill_in('Email', :with => user.email)
      fill_in('Password', :with => user.password)
      click_button('login-btn')
    end

    it "accepts valid signup information" do
      visit new_plant_path
      fill_in('Common name', :with => 'Common Name Example')
      fill_in('Scientific name', :with => 'Species Name example')
      fill_in('Habitat type', :with => 'Jungle')
      fill_in('Sunlight tolerance', :with => 'Very low')
      click_on("Add plant")
      expect(page).to have_content("Plant was successfully created")
    end
  end
end