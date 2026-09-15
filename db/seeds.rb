puts "Cleaning database..."
Notification.destroy_all
ActivityLog.destroy_all
Comment.destroy_all
Task.destroy_all
Project.destroy_all
Team.destroy_all
Membership.destroy_all
Organization.destroy_all
User.destroy_all

puts "Seeding Users..."
owner = User.create!(
  first_name: "Alice",
  last_name: "Walker",
  email: "owner@vertex.io",
  password: "Password123!",
  bio: "CTO & Co-founder"
)

admin = User.create!(
  first_name: "Bob",
  last_name: "Martinez",
  email: "admin@vertex.io",
  password: "Password123!",
  bio: "Lead Platform Architect"
)

member = User.create!(
  first_name: "Charlie",
  last_name: "Dev",
  email: "dev@vertex.io",
  password: "Password123!",
  bio: "Full Stack Engineer"
)

puts "Seeding Organization..."
org = Organization.create!(name: "Vertex Labs", slug: "vertex-labs")

Membership.create!(organization: org, user: owner, role: "owner")
Membership.create!(organization: org, user: admin, role: "admin")
Membership.create!(organization: org, user: member, role: "member")

puts "Seeding Teams & Projects..."
eng_team = Team.create!(organization: org, name: "Core Engineering", description: "Infra and platform features")
project = Project.create!(organization: org, team: eng_team, name: "API Gateway", key: "API")

puts "Seeding Tasks..."
tasks = [
  { title: "Implement Redis Caching Layer", status: "backlog", priority: "high", creator: owner, assignee: admin },
  { title: "Configure Puma Clustering", status: "todo", priority: "medium", creator: admin, assignee: member },
  { title: "Resolve N+1 Queries on Dashboard", status: "in_progress", priority: "urgent", creator: member, assignee: member },
  { title: "Review OpenSSL 3.0 Migration", status: "review", priority: "low", creator: owner, assignee: admin },
  { title: "Setup Database Replicas", status: "done", priority: "high", creator: owner, assignee: owner }
]

tasks.each_with_index do |t, idx|
  task = project.tasks.create!(
    organization: org,
    creator: t[:creator],
    assignee: t[:assignee],
    title: t[:title],
    description: "Detailed instructions and operational specs for #{t[:title]}.",
    status: t[:status],
    priority: t[:priority],
    position: idx + 1,
    due_date: Date.today + (idx + 2).days
  )

  task.comments.create!(
    user: owner,
    body: "Initial checklist approved. Please proceed according to RFC specifications."
  )
end

puts "Seed finished successfully!"
puts "Login with:"
puts "  Email: owner@vertex.io"
puts "  Password: Password123!"