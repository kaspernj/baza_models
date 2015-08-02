require 'spec_helper'

describe BazaModels::Model::Queries do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  it "#find" do
    user.save!
    user_found = User.find(user.id)
    expect(user_found.email).to eq "test@example.com"
  end

  it "#find_by" do
    user.save!
    user_found = User.find_by(id: 1, email: "test@example.com")
    expect(user_found.email).to eq "test@example.com"
  end
end
