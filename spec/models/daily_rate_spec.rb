require 'rails_helper'

RSpec.describe DailyRate, type: :model do
  it { is_expected.to validate_presence_of(:date) }
  it { is_expected.to validate_presence_of(:rate) }
  it { is_expected.to validate_uniqueness_of(:date) }
end
