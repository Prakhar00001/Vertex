require "rails_helper"

RSpec.describe OrganizationPolicy, type: :policy do
  let(:user) { User.create!(first_name: "A", last_name: "B", email: "a@b.com", password: "Password123!") }
  let(:org) { Organization.create!(name: "Test", slug: "test-org") }

  it "permits member to show" do
    Membership.create!(user: user, organization: org, role: "member")
    policy = OrganizationPolicy.new(user, org)
    expect(policy.show?).to be true
  end
end