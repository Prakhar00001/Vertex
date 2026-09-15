require "rails_helper"

RSpec.describe "Api::V1::Projects", type: :request do
  let(:user) { User.create!(first_name: "Api", last_name: "User", email: "api@test.com", password: "Password123!") }
  let(:org) { Organization.create!(name: "API Org", slug: "api-org") }

  before do
    Membership.create!(user: user, organization: org, role: "owner")
  end

  it "returns projects using token authentication" do
    get api_v1_projects_path, headers: {
      "Authorization" => "Bearer #{user.api_token}",
      "X-Organization-Slug" => org.slug
    }
    expect(response).to have_http_status(:success)
  end
end