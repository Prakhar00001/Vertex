require "rails_helper"

RSpec.describe "Api::V1::Tasks", type: :request do
  let(:user) { User.create!(first_name: "Api", last_name: "User", email: "api2@test.com", password: "Password123!") }
  let(:org) { Organization.create!(name: "API Org 2", slug: "api-org-2") }
  let(:project) { Project.create!(organization: org, name: "Platform", key: "PLT") }

  before do
    Membership.create!(user: user, organization: org, role: "owner")
  end

  it "lists tasks under a project" do
    get api_v1_project_tasks_path(project_id: project.id), headers: {
      "Authorization" => "Bearer #{user.api_token}",
      "X-Organization-Slug" => org.slug
    }
    expect(response).to have_http_status(:success)
  end
end