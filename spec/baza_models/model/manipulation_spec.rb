require "spec_helper"

describe BazaModels::Model::Manipulation do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  it "#created_at" do
    expect(user.created_at).to be_nil
    user.save!
    expect(user.created_at).not_to be_nil
  end

  it "#updated_at" do
    expect(user.updated_at).to be_nil
    user.save!
    expect(user.updated_at).not_to be_nil
    old_updated_at = user.updated_at
    sleep 1
    user.email = "test2@example.com"
    user.save!
    expect(user.updated_at).not_to eq old_updated_at
  end
end
