require 'rails_helper'

RSpec.describe PagesController, type: :controller do
  setup :activate_authlogic

  describe 'show' do
    context 'faq' do
      it 'shows the faq page' do
        get :show, id: 'faq'
        expect(response).to render_template(:faq)
      end
    end

    context 'given a page id for a nonexistent page' do
      it 'shows a failure message' do
        get :show, id: 'nonsense'
        expect(response.body).to eq "nonsense doesn't exist."
      end
    end
  end

end
