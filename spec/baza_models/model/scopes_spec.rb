require "spec_helper"

describe BazaModels::Model::Scopes do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  before do
    user.save!
    role_user.save!
    role_admin.save!
  end

  it "works with where" do
    expect(Role.admin_roles.to_a).to eq [role_admin]
  end

  it "joins as well" do
    expect(User.admin_roles_scope.to_a).to eq [user]
  end
end
