FactoryBot.define do
  factory :organization do
    name { "Vertex Core" }
    slug { "vertex-#{SecureRandom.hex(4)}" }
  end
end