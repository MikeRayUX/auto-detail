# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StaticPages::HomePagesController, type: :controller do
  before(:each) do
    pricing = create(:region_pricing)
  end

  context 'rendering pages' do
    it 'should render home page' do
      get :show
      expect(response).to render_template('show')
    end
  end
end
