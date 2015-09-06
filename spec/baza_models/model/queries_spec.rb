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

  describe "#find_by" do
    it "finds existing models" do
      user.save!
      user_found = User.find_by(id: 1, email: "test@example.com")
      expect(user_found.email).to eq "test@example.com"
    end

    it "returns false when nothing is found" do
      user_found = User.find_by(id: 1, email: "test@example.com")
      expect(user_found).to eq false
    end

    it "#find_by!" do
      expect { User.find_by!(email: "doesntexist@example.com") }.to raise_error(BazaModels::Errors::RecordNotFound)
    end
  end

  describe "#find_or_initialize_by" do
    it "finds existing models" do
      user.save!
      user_found = User.find_or_initialize_by(id: 1, email: "test@example.com")
      expect(user_found.new_record?).to eq false
      expect(user_found.persisted?).to eq true
    end

    it "returns false when nothing is found" do
      user_found = User.find_or_initialize_by(email: "test@example.com")
      expect(user_found.new_record?).to eq true
      expect(user_found.persisted?).to eq false
    end
  end
end
