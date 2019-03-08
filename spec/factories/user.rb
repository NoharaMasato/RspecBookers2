# frozen_string_literal: true

FactoryBot.define do
  password = Faker::Internet.password

  factory :user do
    # association :master_hospital, factory: :master_hospital
    sequence(:email) { |n| "example#{n}@test.com" }
    sequence(:name) { |n| "name#{n}" }
    sequence(:introduction) { |n| "introduction#{n}" }
    password { password }
    password_confirmation { password }

    trait :no_name do
      name {}
    end

    trait :introduction_length_exceed_max do
      introduction {Faker::Lorem.characters(51)}
    end

    trait :create_with_image do
      avatar_image {Refile::FileDouble.new("dummy", "logo.png", content_type: "image/png")}
    end

    trait :create_with_books do
      after(:create) do |user|
        create_list(:book, 3, user: user)
      end
    end
  end
end
