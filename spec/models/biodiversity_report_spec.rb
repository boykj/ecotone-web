require 'rails_helper'

RSpec.describe BiodiversityReport, type: :model do
  subject(:report) { build :biodiversity_report, id: 'FAKE' }

  context 'when created' do
    it { is_expected.to have_attributes(
      measured_on: Date.today,
      measured_at: Date.today,
      temperature: 1.5,
      species_richness: 1
    ) }
    it { is_expected.to be_valid }

    it 'has a string representation incorporating its id' do
      expect(report.to_s).to eq("Biodiversity Report #{report.id}")
    end

    it 'has a byline consisting of the author name, date and time' do
      expect(report.byline).to eq("by #{report.author} on #{report.measured_on.to_s(:long)} at #{report.measured_at.to_s(:ampm)}")
    end
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:temperature).allow_nil }
    it { is_expected.to validate_numericality_of(:species_richness).only_integer.is_greater_than(0) }
    it { is_expected.to validate_numericality_of(:diversity_index).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:measured_on) }
    it { is_expected.to validate_presence_of(:measured_at) }
    it { is_expected.to validate_attachment_content_type(:photo).allowing('image/jpg', 'image/png') }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:author).class_name('User') }
    it { is_expected.to belong_to(:plot) }
    it { is_expected.to have_one(:soil_sample) }
    it { is_expected.to accept_nested_attributes_for(:soil_sample).allow_destroy(true) }
    it { is_expected.to have_one(:fungi_sample) }
    it { is_expected.to accept_nested_attributes_for(:fungi_sample).allow_destroy(true) }
    it { is_expected.to have_one(:lichen_sample) }
    it { is_expected.to accept_nested_attributes_for(:lichen_sample).allow_destroy(true) }
    it { is_expected.to have_one(:nonvascular_plant_sample) }
    it { is_expected.to accept_nested_attributes_for(:nonvascular_plant_sample).allow_destroy(true) }
    it { is_expected.to have_many(:macroinvertebrate_samples) }
    it { is_expected.to accept_nested_attributes_for(:macroinvertebrate_samples).allow_destroy(true) }
    it { is_expected.to have_many(:plant_samples) }
    it { is_expected.to accept_nested_attributes_for(:plant_samples).allow_destroy(true) }
    it { is_expected.to have_attached_file(:photo) }

    it 'triggers destroy_associated_samples after destroy' do
      expect(report).to receive(:destroy_associated_samples)
      report.destroy
    end

    it 'destroys associated samples when destroyed' do
      create(:soil_sample, biodiversity_report: report)
      create(:fungi_sample, biodiversity_report: report)
      create(:lichen_sample, biodiversity_report: report)
      create(:nonvascular_plant_sample, biodiversity_report: report)
      create(:macroinvertebrate_sample, biodiversity_report: report)
      create(:plant_sample, biodiversity_report: report)
      expect { report.destroy }.to change { SoilSample.count &&
                                            FungiSample.count &&
                                            LichenSample.count &&
                                            NonvascularPlantSample.count &&
                                            MacroinvertebrateSample.count &&
                                            PlantSample.count
                                          }.from(1).to(0)
    end
  end

  describe 'editability' do
    let(:author) { report.author }
    let(:admin) { build(:user, :admin) }

    it 'is editable by its author, who is not an admin' do
      expect(report).to be_editable_by(author)
    end

    it 'is editable by an admin, who is not the author' do
      expect(report).to be_editable_by(admin)
    end

    it 'is not editable by anyone else' do
      expect(report).to_not be_editable_by(build(:user))
    end
  end
end
