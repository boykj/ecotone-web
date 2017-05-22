require 'rails_helper'

#source: https://everydayrails.com/2012/04/07/testing-series-rspec-controllers.html

RSpec.describe PlotsController, type: :controller do

  let(:general_user) { FactoryGirl.build(:user) }
  let(:admin_user) { FactoryGirl.build(:user, :admin) }
  let(:plot) { FactoryGirl.create(:plot) }
  let(:plant) { create(:plant) }
  let(:invalid_plot) { FactoryGirl.build(:invalid_plot) }

  before(:each) do
    allow(controller).to receive(:current_user).and_return(admin_user)
  end

  describe "#index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "#show" do
    it "returns http success" do
      get :show, params: { id: plot.id }
      expect(response).to have_http_status(:success)
    end
  end

  describe "#new" do
    it "returns http success" do
      get :new
      expect(response).to have_http_status(:success)
    end
  end

  describe "#edit" do
    it "returns http success" do
      get :edit, params: { id: plot.id }
      expect(response).to have_http_status(:success)
    end
  end


  describe "#create" do

    context "with valid attributes" do

      it "creates new plot" do
        plot_params = FactoryGirl.attributes_for(:plot, featured_plant_id: plant.id)
        expect { post :create, params: { :plot => plot_params } }.to change(Plot, :count).by(1)
      end

      it "redirects to index" do
        post :create, params: { plot: FactoryGirl.attributes_for(:plot, featured_plant_id: plant.id) }
        expect(response).to redirect_to plots_path
      end

      it "produces correct flash notice" do
        post :create, params: { plot: FactoryGirl.attributes_for(:plot, featured_plant_id: plant.id) }
        assert_equal 'Plot was successfully created.', flash[:success]
      end

    end

    context "with invalid attributes" do

      it "does not save new plot" do
        plot_params = FactoryGirl.attributes_for(:invalid_plot)
        expect { post :create, params: { :plot => plot_params } }.to_not change(Plot, :count)
      end

      it "does not redirect to index" do
        post :create, params: { plot: FactoryGirl.attributes_for(:invalid_plot) }
        expect(response).to_not redirect_to plots_path
      end

    end

  end

  describe "#update" do

    before(:each) do
      @plot = create(:plot, plot_id: 1)
    end

    context "with valid attributes" do

      it "updates plot attributes" do
        put :update, params: { id: @plot, plot: FactoryGirl.attributes_for(:plot, plot_id: 2) }
        @plot.reload
        expect(@plot.plot_id).to eq(2)
      end

      it "redirects to the updated plot" do
        put :update, params: { id: @plot , plot: FactoryGirl.attributes_for(:plot) }
        expect(response).to redirect_to @plot
      end

      it "produces correct flash notice" do
        put :update, params: { id: @plot , plot: FactoryGirl.attributes_for(:plot) }
        assert_equal 'Plot was successfully updated.', flash[:success]
      end

    end

    context "with invalid attributes" do

      it "does not update attributes" do
        put :update, params: { id: @plot, plot: FactoryGirl.attributes_for(:plot, plot_id: nil) }
        @plot.reload
        expect(@plot.plot_id).to eq(1)
      end

      it "does not redirect to updated plot" do
        put :update, params: { id: @plot, plot: FactoryGirl.attributes_for(:invalid_plot) }
        expect(response).to_not redirect_to @plpot
      end

    end

  end

  describe "#destroy" do

    before(:each) do
      @plot = create(:plot)
    end

    it "deletes plant" do
      expect { delete :destroy, params: { id: @plot } }.to change(Plot, :count).by(-1)
    end

    it "redirects to index" do
      delete :destroy, params: { id: @plot }
      expect(response).to redirect_to plots_url
    end

    it "produces correct flash notice" do
      delete :destroy, params: { id: @plot }
      assert_equal 'Plot was successfully destroyed.', flash[:success]
    end

  end

  describe "all plants controller methods" do

    context "user is not admin" do
      before(:each) do
        allow(controller).to receive(:current_user).and_return(general_user)
      end

      it "#new redirects" do
        get :new
        expect(response).to redirect_to :root
      end

      it "#create redirects" do
        get :create, params: { plant: FactoryGirl.attributes_for(:plot) }
        expect(response).to redirect_to :root
      end

      before(:each) do
        @plot = create(:plot)
      end

      it "#update redirects" do
        put :update, params: { id: @plot, plot: FactoryGirl.attributes_for(:plot) }
        expect(response).to redirect_to :root
      end

      it "redirects to index" do
        delete :destroy, params: { id: @plot }
        expect(response).to redirect_to :root
      end

    end
  end
end

