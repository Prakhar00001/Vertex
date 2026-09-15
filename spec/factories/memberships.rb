FactoryBot.define do
  factory :membership do
    user
    organization
    role { "member" }
  end
end