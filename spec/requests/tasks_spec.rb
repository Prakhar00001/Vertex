require "rails_helper"

RSpec.describe "Tasks", type: :request do
  let(:user) { User.create!(first_name: "A", last_name: "B", email: "task_user@test.com", password: "Password123!") }
  let(:org) { Organization.create!(name: "Acme", slug: "acme-task-test") }
  let(:project) { Project.create!(organization: org, name: "Core", key: "CR") }

  before do
    Membership.create!(user: user, organization: org, role: "owner")
    sign_in user
  end

  it "creates a new task via service" do
    post tenant_project_tasks_path(org_slug: org.slug, project_id: project.id), params: {
      task: { title: "New Feature", priority: "high", status: "todo" }
    }
    expect(response).to redirect_to(project_path(org_slug: org.slug, id: project.id))
  end
end