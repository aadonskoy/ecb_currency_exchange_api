require 'rails_helper'

RSpec.describe Api::V1::RatesController, type: :request do
  describe 'GET #show' do
    let(:date) { '2012-10-24' }
    let(:db_date) { date.to_date }
    let(:daily_rate) { create(:daily_rate, date: db_date) }
    let(:parameters) { { amount: 10 } }
    let(:request_example) do
      get api_v1_rate_path(date), params: parameters
    end

    before(:each) do |example|
      before_request
      request_example unless example.metadata[:skip_request]
    end

    subject { response }

    context 'success' do
      let!(:before_request) { daily_rate }

      it { is_expected.to have_http_status(:success) }
    end

    context 'not found', skip_request: true do
      let(:before_request) { }

      it 'produces not_found error' do
        expect { request_example }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'invalid date format' do
      let!(:before_request) { daily_rate }
      let(:db_date) { Date.current }
      let(:date) { '2016-30-30' }

      it { is_expected.to have_http_status(:unprocessable_entity) }
      it { expect(JSON.parse(response.body)['error']).to eq('Invalid date') }
    end
  end
end
