require "rails_helper"

RSpec.describe ProjectPolicy, type: :policy do
  subject { described_class.new(user, project) }

  let(:organization) { Organization.create!(name: "Test Org", slug: "test-org") }
  let(:owner) { User.create!(first_name: "John", last_name: "Doe", email: "owner@test.com", password: "password123") }
  let(:member) { User.create!(first_name: "Jane", last_name: "Smith", email: "member@test.com", password: "password123") }
  let(:outsider) { User.create!(first_name: "Alien", last_name: "User", email: "alien@test.com", password: "password123") }

  let(:project) { Project.create!(organization: organization, name: "Core", key: "COR") }

  before do
    Membership.create!(user: owner, organization: organization, role: "owner")
    Membership.create!(user: member, organization: organization, role: "member")
  end

  context "when user is owner" do
    let(:user) { owner }
    it { is_expected.to permit_action(:create) }
    it { is_expected.to permit_action(:destroy) }
  end

  context "when user is member" do
    let(:user) { member }
    it { is_expected.to permit_action(:show) }
    it { is_expected.to forbid_action(:destroy) }
  end

  context "when user does not belong to organization" do
    let(:user) { outsider }
    it { is_expected.to forbid_action(:show) }
  end
end