require "rails_helper"

RSpec.describe TaskPolicy, type: :policy do
  let(:org) { Organization.create!(name: "Test", slug: "test-org-2") }
  let(:user) { User.create!(first_name: "A", last_name: "B", email: "a2@b.com", password: "Password123!") }
  let(:project) { Project.create!(organization: org, name: "Core", key: "CR") }
  let(:task) { Task.create!(organization: org, project: project, creator: user, title: "Task") }

  it "permits organization users to update" do
    Membership.create!(user: user, organization: org, role: "member")
    policy = TaskPolicy.new(user, task)
    expect(policy.update?).to be true
  end
end