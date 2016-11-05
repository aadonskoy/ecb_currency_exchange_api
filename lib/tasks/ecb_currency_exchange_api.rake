namespace :ecb_currency_exchange_api do
  desc 'Fetch the newest rates data from the ECB service'
  task fetch: :environment do
    puts '=== Fetching data... ==='
    FetchRatesService.fetch_new_data
    puts '=== Fetching data completed ==='
  end
end
