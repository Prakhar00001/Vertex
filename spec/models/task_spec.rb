require "rails_helper"

RSpec.describe Task, type: :model do
  it "defaults status to backlog" do
    org = Organization.create!(name: "Acme", slug: "acme-test-2")
    user = User.create!(first_name: "J", last_name: "D", email: "jd@test.com", password: "Password123!")
    project = Project.create!(organization: org, name: "Core", key: "CR")
    task = Task.create!(organization: org, project: project, creator: user, title: "Test")
    expect(task.status).to eq("backlog")
  end
end