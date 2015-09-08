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
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` WHERE (email = 'test@example.com')"
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

  context "#group, #order" do
    before do
      user
      role_user
      role_admin

      user2 = User.create!(email: "another@example.com")
      Role.create!(user: user2, role: "administrator")
      Role.create!(user: user2, role: "user")
    end

    it "groups results" do
      roles = Role.group(:role).order(:role).to_a

      expect(roles.length).to eq 2
      expect(roles.map(&:role)).to eq ["administrator", "user"]
    end
  end

  it "#any? #empty? #none? #count #length" do
    expect(User.any?).to eq false
    expect(User.empty?).to eq true
    expect(User.none?).to eq true
    expect(User.count).to eq 0
    expect(User.length).to eq 0
    user.save!
    expect(User.any?).to eq true
    expect(User.empty?).to eq false
    expect(User.none?).to eq false
    expect(User.count).to eq 1
    expect(User.length).to eq 1
  end

  it "#find" do
    expect(User.all.find(1)).to eq nil
    user.save!
    expect(User.all.find(user.id)).to eq user
  end

  describe "#destroy_all" do
    it "destroys the correct models" do
      role_user.save!
      role_admin.save!

      Role.where(role: "user").destroy_all

      expect { role_user.reload }.to raise_error(BazaModels::Errors::RecordNotFound)
      role_admin.reload
    end
  end
end
