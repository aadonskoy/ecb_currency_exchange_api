module Api
  module V1
    class RatesController < ApplicationController
      def show
        daily_rate = DailyRate.nearest_to_date(parsed_date).last!
        unless performed?
          render json: { result: daily_rate.usd_to_euro(params[:amount].to_f) }, status: :ok
        end
      end

      def parsed_date
        params[:id].to_date
      rescue => error
        render json: { error: 'Invalid date' }, status: :unprocessable_entity
      end
    end
  end
end
