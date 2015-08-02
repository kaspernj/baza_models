require 'spec_helper'

describe BazaModels::Query do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  context "#where" do
    before do
      user.save!
    end

    it 'supports hashes' do
      query = User.where(email: "test@example.com")
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` WHERE `users`.`email` = 'test@example.com'"
      expect(query.to_a).to eq [user]
    end

    it 'supports strings' do
      query = User.where("email = 'test@example.com'")
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` WHERE email = 'test@example.com'"
      expect(query.to_a).to eq [user]
    end
  end

  context '#joins' do
    before do
      user.save!
      role_admin.save!
    end

    it 'joins with symbols and relationships' do
      query = User.joins(:roles).where(roles: {role: 'administrator'})
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` INNER JOIN `roles` ON `roles`.`user_id` = `users`.`id` WHERE `roles`.`role` = 'administrator'"
      expect(query.to_a).to eq [user]
    end

    it 'joins with strings' do
      query = User.joins('LEFT JOIN roles ON roles.user_id = users.id').where(roles: {role: 'administrator'})
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` LEFT JOIN roles ON roles.user_id = users.id WHERE `roles`.`role` = 'administrator'"
      expect(query.to_a).to eq [user]
    end
  end
end
