# frozen_string_literal: true

FactoryBot.define do
  factory :book do
    # association :master_hospital, factory: :master_hospital
    sequence(:title) { |n| "title#{n}" }
    sequence(:body) { |n| "body#{n}" }

    trait :no_title do
      title {}
    end

    trait :no_body do
      body {}
    end
  end
end
