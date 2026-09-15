require "rails_helper"

RSpec.describe "Projects", type: :request do
  let(:user) { User.create!(first_name: "A", last_name: "B", email: "test@user.com", password: "Password123!") }
  let(:org) { Organization.create!(name: "Acme", slug: "acme-test-3") }

  before do
    Membership.create!(user: user, organization: org, role: "owner")
    sign_in user
  end

  it "renders project index successfully" do
    get tenant_projects_path(org_slug: org.slug)
    expect(response).to have_http_status(:success)
  end
end