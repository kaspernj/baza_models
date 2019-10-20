require "spec_helper"

describe BazaModels::Model::HasManyRelations do
  include DatabaseHelper

  let(:organization) { Organization.new }
  let(:user) { User.new(email: "test@example.com", organization: organization) }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  context "destroy" do
    before do
      user.save!
    end

    it "destroyes through has_many" do
      role_user.save!
      user.destroy!
      expect { user.reload }.to raise_error(BazaModels::Errors::RecordNotFound)
      expect { role_user.reload }.to raise_error(BazaModels::Errors::RecordNotFound)
    end

    it "restricts through has_many" do
      role_admin.save!
      expect { user.destroy! }.to raise_error(BazaModels::Errors::InvalidRecord)
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
        expect(user.admin_roles.to_sql).to eq "SELECT `roles`.* FROM `roles` WHERE `roles`.`user_id` = #{user.id} AND `roles`.`role` = 'administrator'"
      end
    end
  end

  describe "#<<" do
    it "adds models to persisted parent" do
      organization.save!
      organization.users << User.create!(email: "test@example.com")

      expect(organization.users.count).to eq 1
      expect(organization.users.first.email).to eq "test@example.com"
    end

    it "adds models to new parent" do
      organization.users << User.new(email: "test1@example.com")
      organization.users << User.new(email: "test2@example.com")

      expect(organization.users.count).to eq 2

      organization.save!

      expect(organization.users.count).to eq 2
    end
  end
end
