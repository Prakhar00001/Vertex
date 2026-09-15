require "rails_helper"

RSpec.describe Project, type: :model do
  it "upcases the key before validation" do
    org = Organization.create!(name: "Acme", slug: "acme-test")
    project = Project.create!(organization: org, name: "Core", key: "low")
    expect(project.key).to eq("LOW")
  end
end