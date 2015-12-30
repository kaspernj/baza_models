require "spec_helper"

describe BazaModels::Query do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  context "#where" do
    before do
      user.save!
    end

    it "supports hashes" do
      query = User.where(email: "test@example.com")
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` WHERE `users`.`email` = 'test@example.com'"
      expect(query.to_a).to eq [user]
    end

    it "supports strings" do
      query = User.where("email = 'test@example.com'")
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` WHERE (email = 'test@example.com')"
      expect(query.to_a).to eq [user]
    end

    it "supports arrays" do
      query = User.where(["?=?", :email, "test@example.com"])
      expect(query.to_a).to eq [user]
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` WHERE (`users`.`email`='test@example.com')"
    end
  end

  context '#joins' do
    before do
      user.save!
      role_admin.save!
    end

    it "joins with symbols and relationships" do
      query = User.joins(:roles).where(roles: {role: "administrator"})
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` INNER JOIN `roles` ON `roles`.`user_id` = `users`.`id` WHERE `roles`.`role` = 'administrator'"
      expect(query.to_a).to eq [user]
    end

    it "joins with strings" do
      query = User.joins("LEFT JOIN roles ON roles.user_id = users.id").where(roles: {role: "administrator"})
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` LEFT JOIN roles ON roles.user_id = users.id WHERE `roles`.`role` = 'administrator'"
      expect(query.to_a).to eq [user]
    end

    it "does deep joins" do
      query = Organization.joins(users: :person).to_sql

      expect(query).to include "INNER JOIN `users` ON `users`.`organization_id` = `organizations`.`id`"
      expect(query).to include "INNER JOIN `persons` ON `persons`.`user_id` = `users`.`id`"
    end

    it "doesn't double join with symbols" do
      query = Organization.joins(:users, :users, users: :person).to_sql

      join_sql = "INNER JOIN `users` ON `users`.`organization_id` = `organizations`.`id`"
      count = query.scan(/#{Regexp.escape(join_sql)}/).length
      expect(count).to eq 1
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
      expect(roles.map(&:role)).to eq %w(administrator user)
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

  it "#first" do
    role_user.save!
    role_admin.save!

    expect(Role.first).to eq role_user
    expect(Role.last).to eq role_admin
  end

  describe "#order" do
    it "converts symbols to escaped strings" do
      sql = Role.order(:role).to_sql
      expect(sql).to end_with "ORDER BY `roles`.`role`"
    end
  end

  describe "#reverse_order" do
    before do
      role_user.save!
      role_admin.save!
    end

    it "reverses ASC strings" do
      sql = Role.order("roles.role ASC").reverse_order.to_sql
      expect(sql).to end_with " DESC"
    end

    it "reverses DESC strings" do
      sql = Role.order("roles.role DESC").reverse_order.to_sql
      expect(sql).to end_with " ASC"
    end

    it "reverses symbols" do
      sql = Role.order(:role).reverse_order.to_sql
      expect(sql).to end_with " DESC"
    end
  end
end
