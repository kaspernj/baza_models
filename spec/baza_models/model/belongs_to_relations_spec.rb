require 'spec_helper'

describe BazaModels::Model::BelongsToRelations do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  context '#includes' do
    before do
      user.save!
      role_admin.save!
    end

    it 'autoloads via includes on belongs_to relations' do
      query = Role.includes(:user).to_a
      role = query.first

      allow(role.autoloads).to receive(:[]).and_call_original
      expect(role.user).to eq user
      expect(role.autoloads).to have_received(:[]).with(:user)
      expect(role.autoloads[:user]).to eq user
    end
  end

  context "relationships" do
    before do
      user.save!
      role_user.save!
      role_admin.save!
    end

    it "#belongs_to" do
      expect(role_user.user).to eq user
    end
  end
end
