FactoryBot.define do
  factory :user do
    organization

    email { "user@example.com" }
  end
end
