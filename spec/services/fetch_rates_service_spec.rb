require 'rails_helper'

RSpec.describe FetchRatesService, type: :service do
  let(:date) { '2016-11-06' }
  let(:rate) { 1.7 }

  let(:service_data) { service_raw_rate(date, rate) }

  let(:response_example) do
    {
      'GenericData' => {
        'DataSet' => {
          'Series' => {
            'Obs' => service_data
          }
        }
      }
    }
  end

  describe 'fetch_new_data' do
    it 'adds data to DailyRate' do
      stub_webservice

      expect do
        described_class.fetch_new_data
      end.to change { DailyRate.count }.from(0)
    end

    context 'will not add the data twice' do
      it 'does not add the same data to the DailyRate table twice' do
        stub_webservice

        described_class.fetch_new_data
        expect do
          described_class.fetch_new_data
        end.not_to change { DailyRate.count }
      end
    end
  end

  describe 'request_url' do
    let(:from_date) { Date.new(2016, 11, 05) }
    let(:to_date) { nil }

    subject { described_class.request_url(from_date, to_date) }

    context 'without to_date' do
      it { is_expected.to eq("https://sdw-wsrest.ecb.europa.eu/service/data/EXR/D.USD.EUR.SP00.A?startPeriod=#{from_date}") }
    end

    context 'with to_date' do
      let(:to_date) { from_date + 1.day }
      it { is_expected.to eq("https://sdw-wsrest.ecb.europa.eu/service/data/EXR/D.USD.EUR.SP00.A?startPeriod=#{from_date}&endPeriod=#{to_date}") }
    end
  end

  describe 'parse_to_db_rows' do
    let(:array_set) do
      [
        { date: '2016-11-06', rate: rate },
        { date: '2016-11-07', rate: rate }
      ]
    end

    let(:hash_set) { { date: date, rate: rate } }
    let(:example_data) { response_example }

    subject { described_class.parse_to_db_rows(example_data) }

    context 'with array' do
      let(:service_data) do
        array_set.map do |ars|
          service_raw_rate(ars[:date], ars[:rate])
        end
      end
      let(:result) do
        [
          described_class.row_to_hash(service_data[0]),
          described_class.row_to_hash(service_data[1])
        ]
      end

      it { is_expected.to eq(result) }
    end

    context 'with hash (for the one date only)' do
      let(:service_data) { service_raw_rate(hash_set[:date], hash_set[:rate]) }
      let(:result) do
        [described_class.row_to_hash(service_data)]
      end

      it { is_expected.to eq(result) }
    end
  end

  describe 'row_to_hash' do
    let(:date) { '2016-11-06' }
    let(:rate) { 1.7 }
    let(:example_data) do
      {
        'ObsDimension' => { 'value' => date },
        'ObsValue' => { 'value' => rate }
      }
    end
    let(:result) { { date: date.to_date, rate: rate } }

    subject { described_class.row_to_hash(example_data) }

    it 'returns correct value' do
      is_expected.to eq(result)
    end
  end

  def stubbed_years
    @stubbed_years ||= Date.current.year - described_class::INITIAL_DATE.year
  end

  def stub_webservice
    # For the sake of simplicity I'm responding just with one date per year.
    stubbed_years.times do |year|
      stub_webservice_response(
        described_class::INITIAL_DATE + year.year,
        described_class::INITIAL_DATE + (year + 1).year)
    end

    stub_webservice_response(
      described_class::INITIAL_DATE + stubbed_years.year,
      Date.current)
    stub_webservice_response(Date.current, Date.current)
  end

  def stub_webservice_response(start_date, end_date = nil)
    sample_rate = 1.8
    url = "https://sdw-wsrest.ecb.europa.eu/service/data/EXR/D.USD.EUR.SP00.A?startPeriod=#{start_date}"
    stubbed_data = [service_raw_rate(start_date, sample_rate)]

    if end_date
      url << "&endPeriod=#{end_date}"
      stubbed_data << service_raw_rate(end_date, sample_rate)
    end

    stub_request(:get, url).to_return(
      body: {
        'GenericData' => {
          'DataSet' => {
            'Series' => {
              'Obs' => stubbed_data
            }
          }
        }
      }.to_json,
      headers: {
        'Content-Type' => 'application/json'
      },
      status: 200
    )
  end

  def service_raw_rate(date, rate)
    {
      'ObsDimension' => { 'value' => date },
      'ObsValue' => { 'value' => rate }
    }
  end
end
