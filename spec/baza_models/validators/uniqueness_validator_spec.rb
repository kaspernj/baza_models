require "spec_helper"

describe BazaModels::Validators::UniquenessValidator do
  include DatabaseHelper

  before do
    User.create!(email: "test@example.com", organization_id: 1)
  end

  it "doesnt accept users with the same email" do
    user2 = User.new(email: "test@example.com", organization_id: 1)
    user2.validate_uniqueness = true

    expect(user2.valid?).to eq false
    expect(user2.errors.full_messages).to eq ["Email isn't unique"]
  end

  it "accepts users from other scope" do
    user2 = User.new(email: "test@example.com", organization_id: 2)
    user2.validate_uniqueness = true

    expect(user2.valid?).to eq true
  end
end
