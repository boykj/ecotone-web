require 'rails_helper'

RSpec.feature "Creating biodiversity reports" do

  let(:user) { create(:user) }

  before do
    create(:plot)
    sign_in(user)
    visit new_biodiversity_report_path
  end

  context "without a soil sample or a plant sample" do

    scenario "as a user providing valid report data" do
      fill_in_report_fields
      click_button('Add biodiversity report')
      expect(page).to have_selector ".alert", text: "Biodiversity report was successfully created."
      expect(page).to have_content(BiodiversityReport.last.to_s)
      click_link(BiodiversityReport.last.to_s)
      expect(page).to have_content('No soil sample')
    end

    scenario "as a user providing invalid report data" do
      click_button('Add biodiversity report')
      expect(page).to have_selector ".alert", text: "The form contains 6 errors."
      page.find("#error_explanation").tap do |error_explanations|
        expect(error_explanations).to have_content("Plot must be specified")
        expect(error_explanations).to have_content("Date can't be blank")
        expect(error_explanations).to have_content("Time can't be blank")
        expect(error_explanations).to have_content("Temperature is not a number")
        expect(error_explanations).to have_content("Biomass estimate is not a number")
        expect(error_explanations).to have_content("Species richness is not a number")
      end
    end

  end

  context "with a soil sample" do

    before { fill_in_report_fields }

    scenario "as a user providing valid soil sample data" do
      fill_in('pH level', :with => '10')
      fill_in('biodiversity_report_soil_sample_attributes_temperature', :with => '100')
      click_button('Add biodiversity report')
      expect(page).to have_selector ".alert", text: "Biodiversity report was successfully created."
      expect(page).to have_content(BiodiversityReport.last.to_s)
      click_link(BiodiversityReport.last.to_s)
      expect(page).to_not have_content('No soil sample')
      expect(page).to have_content('pH Level: 10')
      expect(page).to have_content('Temperature: 100')
    end

    scenario "as a user providing invalid soil sample data" do
      fill_in('pH level', :with => '-1')
      fill_in('biodiversity_report_soil_sample_attributes_temperature', :with => 'fake')
      click_button('Add biodiversity report')
      expect(page).to have_selector ".alert", text: "The form contains 2 errors."
      expect(page.find("#error_explanation")).to have_content("Soil sample ph level must be greater than or equal to 0")
      expect(page.find("#error_explanation")).to have_content("Soil sample temperature is not a number")
      # TODO: soil sample fields should be visible, with values
    end

  end

  def fill_in_report_fields
    select('Plot #1', from: 'Plot')
    fill_in('Date', :with => '09/11/2001')
    fill_in('Time', :with => '04:45 PM')
    fill_in('biodiversity_report_temperature', :with => '72')
    fill_in('biodiversity_report_biomass_estimate', :with => '50')
    fill_in('Species richness', :with => '10')
  end

end