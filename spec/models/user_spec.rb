require "rails_helper"

RSpec.describe User, type: :model do
  it "generates an api_token before validation" do
    user = User.create(first_name: "John", last_name: "Doe", email: "j@example.com", password: "Password123!")
    expect(user.api_token).to be_present
  end
end