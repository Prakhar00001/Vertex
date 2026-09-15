FactoryBot.define do
  factory :activity_log do
    organization
    user
    association :trackable, factory: :task
    action { "task_created" }
  end
end