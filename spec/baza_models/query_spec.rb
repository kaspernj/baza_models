require "spec_helper"

describe BazaModels::Query do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  context "#average" do
    it "calculates the average" do
      5.times do |n|
        User.create! id: n + 1, email: "user#{n}@example.com"
      end

      expect(User.average(:id)).to eq 3.0
      expect(User.where("id >= 4").average(:id)).to eq 4.5
    end
  end

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

    it "supports arrays as values" do
      query = User.where(email: [user.email])

      expect(query.to_a).to eq [user]
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` WHERE `users`.`email` IN ('test@example.com')"
    end
  end

  context "#ids" do
    it "returns the ids of the models" do
      5.times do |n|
        User.create! id: n + 1, email: "user#{n}@example.com"
      end

      expect(User.ids).to eq [1, 2, 3, 4, 5]
      expect(User.where("id >= 3").ids).to eq [3, 4, 5]
    end
  end

  context "#joins" do
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

  it "#any? #empty? #none? #count #length #size" do
    expect(User.any?).to eq false
    expect(User.empty?).to eq true
    expect(User.none?).to eq true
    expect(User.count).to eq 0
    expect(User.length).to eq 0
    expect(User.size).to eq 0
    user.save!
    expect(User.any?).to eq true
    expect(User.empty?).to eq false
    expect(User.none?).to eq false
    expect(User.count).to eq 1
    expect(User.length).to eq 1
    expect(User.size).to eq 1
  end

  it "#find" do
    expect { User.all.find(1) }.to raise_error(BazaModels::Errors::RecordNotFound)
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

  describe "#maximum" do
    it "returns the maximum" do
      5.times do |n|
        User.create! id: n + 1, email: "user#{n}@example.com"
      end

      expect(User.maximum(:id)).to eq 5
      expect(User.where("id < 4").maximum(:id)).to eq 3
    end
  end

  describe "#minimum" do
    it "returns the minimum" do
      5.times do |n|
        User.create! id: n + 1, email: "user#{n}@example.com"
      end

      expect(User.minimum(:id)).to eq 1
      expect(User.where("id >= 3").minimum(:id)).to eq 3
    end
  end

  describe "#order" do
    it "converts symbols to escaped strings" do
      sql = Role.order(:role).to_sql
      expect(sql).to end_with "ORDER BY `roles`.`role`"
    end
  end

  describe "#pluck" do
    it "returns the given columns in an array" do
      5.times do |n|
        User.create! id: n + 1, email: "user#{n + 1}@example.com"
      end

      expect(User.pluck(:id, :email)).to eq [
        [1, "user1@example.com"], [2, "user2@example.com"], [3, "user3@example.com"], [4, "user4@example.com"], [5, "user5@example.com"]
      ]
      expect(User.where("id >= 4").pluck(:id, :email)).to eq [[4, "user4@example.com"], [5, "user5@example.com"]]
      expect(User.pluck(:id)).to eq [1, 2, 3, 4, 5]
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

  describe "#select" do
    it "selects extra columns" do
      user.save!
      role_user.save!

      role = Role.joins(:user).select("roles.*, users.email AS user_email").first

      expect(role.user_email).to eq "test@example.com"
    end
  end

  describe "#sum" do
    it "returns the sum" do
      5.times do |n|
        User.create! id: n + 1, email: "user#{n}@example.com"
      end

      expect(User.sum(:id)).to eq 15.0
      expect(User.where("id >= 3").sum(:id)).to eq 12.0
    end
  end

  it "#new" do
    user.save!
    expect(user.roles.length).to eq 0
    expect(user.roles.count).to eq 0

    role = user.roles.new(role: "admin")
    expect(role.new_record?).to eq true
    expect(user.roles.length).to eq 1
    expect(user.roles.count).to eq 0

    role.save!

    expect(user.roles.length).to eq 1
    expect(user.roles.count).to eq 1
    expect(user.roles.to_a).to eq [role]
  end
end
