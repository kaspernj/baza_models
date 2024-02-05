require "spec_helper"

describe BazaModels::Model::Delegation do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }

  it "delegates methods" do
    user.save!
    role_user.save!

    expect(role_user.email).to eq "test@example.com"
    expect(role_user.user_created_at).to eq user.created_at
  end
end
