require "spec_helper"

describe BazaModels::Model::Manipulation do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  it "#created_at" do
    expect(user.created_at).to eq nil
    user.save!
    expect(user.created_at).to_not eq nil
  end

  it "#updated_at" do
    expect(user.updated_at).to eq nil
    user.save!
    expect(user.updated_at).to_not eq nil
    old_updated_at = user.updated_at
    sleep 1
    user.email = "test2@example.com"
    user.save!
    expect(user.updated_at).to_not eq old_updated_at
  end
end
