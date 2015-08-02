require 'spec_helper'

describe BazaModels::Model::HasManyRelations do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  context 'destroy' do
    before do
      user.save!
    end

    it 'destroyes through has_many' do
      role_user.save!
      user.destroy!
      expect { user.reload }.to raise_error(BazaModels::Errors::RecordNotFound)
      expect { role_user.reload }.to raise_error(BazaModels::Errors::RecordNotFound)
    end

    it 'restricts through has_many' do
      role_admin.save!
      expect { user.destroy! }.to raise_error(BazaModels::Errors::InvalidRecord)
    end
  end

  context '#includes' do
    before do
      user.save!
      role_admin.save!
    end

    it 'autoloads via includes on has_many relations' do
      query = User.includes(:roles).to_a
      user = query.first

      expect(user.autoloads.fetch(:roles)).to eq [role_admin]
      expect(user.roles.__send__(:any_mods?)).to eq false
      expect(user.roles.__send__(:any_wheres_other_than_relation?)).to eq false
      expect(user.roles.__send__(:autoloaded_on_previous_model?)).to eq true
      expect(user.roles.to_enum).to eq [role_admin]
    end
  end

  context "relationships" do
    before do
      user.save!
      role_user.save!
      role_admin.save!
    end

    describe "#has_many" do
      it "returns whole collections without arguments" do
        expect(user.roles.to_a).to eq [role_user, role_admin]
      end

      it "supports class_name and proc-arguments" do
        expect(user.admin_roles.to_a).to eq [role_admin]
        expect(user.admin_roles.to_sql).to eq "SELECT `roles`.* FROM `roles` WHERE `roles`.`user_id` = '#{user.id}' AND `roles`.`role` = 'administrator'"
      end
    end
  end
end
