FactoryGirl.define do
  factory :daily_rate do
    sequence(:date) { |day| Date.current - 1.day }
    rate { 1.0 }
  end
end
