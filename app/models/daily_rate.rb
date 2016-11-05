class DailyRate < ApplicationRecord
  validates :date, :rate, presence: true
  validates :date, uniqueness: true

  def self.nearest_to_date(selected_date)
    where('date <= ?', selected_date).order(:date)
  end

  def usd_to_euro(usd)
    (usd * rate * 100).ceil / 100.0
  end
end
