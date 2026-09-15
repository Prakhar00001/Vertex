FactoryBot.define do
  factory :task do
    organization
    project
    association :creator, factory: :user
    title { "Refactor Tenancy Resolution" }
    status { "todo" }
    priority { "high" }
  end
end