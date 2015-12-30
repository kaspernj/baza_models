require 'spec_helper'

describe BazaModels::Model::BelongsToRelations do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  context "relationships" do
    before do
      user.save!
      role_user.save!
      role_admin.save!
    end

    it "#belongs_to" do
      expect(role_user.user).to eq user
    end

    it "joins correctly" do
      roles = Role.joins(:user).where(role: "administrator", users: {email: "test@example.com"})
      expect(roles.to_a).to eq [role_admin]
    end
  end
end
