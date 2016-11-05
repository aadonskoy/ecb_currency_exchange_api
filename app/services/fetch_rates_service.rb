class FetchRatesService
  INITIAL_DATE = Date.new(2000, 1, 1)

  class << self
    def fetch_new_data
      last_rate = DailyRate.order(:date).last

      unless last_rate
        (Date.current.year - INITIAL_DATE.year).times do |year|
          update_for(start_date: INITIAL_DATE + year.year, end_date: INITIAL_DATE + (year + 1).year)
        end

        last_rate = DailyRate.order(:date).last
      end

      update_for(start_date: last_rate.date, end_date: Date.current)
    end

    def update_for(start_date: INITIAL_DATE, end_date: nil)
      request_result = HTTParty.get(request_url(start_date, end_date))

      if request_result.success?
        parse_to_db_rows(request_result).each do |row|
          DailyRate.find_or_create_by(row)
        end
      end
    end

    def request_url(from_date, to_date)
      start_period = from_date.strftime('%Y-%m-%d')

      url = "https://sdw-wsrest.ecb.europa.eu/service/data/EXR/D.USD.EUR.SP00.A?startPeriod=#{start_period}"

      if to_date.present?
        end_period = to_date.strftime('%Y-%m-%d')
        url << "&endPeriod=#{end_period}"
      else
        url
      end
    end

    def parse_to_db_rows(response_body)
      root_branch = response_body.try(:[], 'GenericData').try(:[], 'DataSet')
        .try(:[], 'Series').try(:[], 'Obs')

      if root_branch
        if root_branch.is_a?(Array)
          root_branch.map { |row| row_to_hash(row) }
        elsif root_branch.is_a?(Hash)
          [row_to_hash(root_branch)]
        end
      end
    end

    def row_to_hash(row)
      {
        date: row.try(:[], 'ObsDimension').try(:[], 'value').to_date,
        rate: row.try(:[], 'ObsValue').try(:[], 'value').to_f
      }
    end
  end
end
