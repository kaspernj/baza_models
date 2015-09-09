require "spec_helper"

describe BazaModels::Model::HasOneRelations do
  include DatabaseHelper

  let!(:user) { User.create!(email: "test@example.com", organization: organization) }
  let!(:role_user) { Role.create!(user: user, role: "user") }
  let!(:role_admin) { Role.create!(user: user, role: "administrator") }
  let!(:organization) { Organization.create!(name: "Test") }

  it "works" do
    expect(user.organization).to eq organization
  end

  it "has one through" do
    expect(role_user.organization).to eq organization
  end
end
