require "rails_helper"

RSpec.describe Organization, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }

    it "validates slug format" do
      valid_org = Organization.new(name: "Acme Corp", slug: "acme-corp")
      expect(valid_org).to be_valid

      invalid_org = Organization.new(name: "Acme Corp", slug: "Acme_Corp!")
      expect(invalid_org).not_to be_valid
    end
  end

  describe "associations" do
    it { should have_many(:memberships).dependent(:destroy) }
    it { should have_many(:users).through(:memberships) }
    it { should have_many(:projects).dependent(:destroy) }
  end
end