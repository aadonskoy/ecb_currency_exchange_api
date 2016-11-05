class DailyRate < ApplicationRecord
  validates :date, :rate, presence: true
  validates :date, uniqueness: true
end
