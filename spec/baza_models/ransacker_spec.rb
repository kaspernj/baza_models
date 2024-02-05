require "spec_helper"

describe BazaModels::Ransacker do
  include DatabaseHelper

  let!(:organization) { Organization.create!(id: 1, name: "Test organization") }
  let!(:person) { Person.create!(id: 1, user: user) }
  let!(:user) { User.create!(id: 1, organization: organization, email: "test@example.com", created_at: "2015-06-17 10:00") }
  let!(:another_user) { User.create!(id: 2, organization: nil, email: "another_user@example.com", created_at: "2015-08-20 6:00") }
  let!(:another_person) { Person.create!(id: 2, user: another_user) }

  it "eq" do
    expect(User.ransack(id_eq: 1).result.to_a).to eq [user]
  end

  it "cont" do
    expect(User.ransack(email_cont: "test").result.to_a).to eq [user]
  end

  describe "lt" do
    it "finds the right models" do
      expect(User.ransack(id_lt: 3).result.to_a).to eq [user, another_user]
    end

    it "excludes the right models" do
      expect(User.ransack(id_lt: 2).result.to_a).to eq [user]
    end
  end

  describe "lteq" do
    it "finds the right models" do
      expect(User.ransack(id_lteq: 2).result.to_a).to eq [user, another_user]
    end

    it "excludes the right models" do
      expect(User.ransack(id_lteq: 1).result.to_a).to eq [user]
    end
  end

  describe "gt" do
    it "finds the right models" do
      expect(User.ransack(id_gt: 0).result.to_a).to eq [user, another_user]
    end

    it "excludes the right models" do
      expect(User.ransack(id_gt: 1).result.to_a).to eq [another_user]
    end
  end

  describe "gteq" do
    it "finds the right models" do
      expect(User.ransack(id_gteq: 1).result.to_a).to eq [user, another_user]
    end

    it "excludes the right models" do
      expect(User.ransack(id_gteq: 2).result.to_a).to eq [another_user]
    end
  end

  describe "since" do
    it "finds the right users" do
      query = User.ransack(created_at_since: "2015-08-20").result
      expect(query.to_a).to eq [another_user]
    end
  end

  it "s" do
    query = User.ransack(s: "email asc")

    expect(query.result.to_a).to eq [another_user, user]
    expect(query.result.to_sql).to eq "SELECT `users`.* FROM `users` ORDER BY `users`.`email` asc"
  end

  it "sorts by sub column" do
    query = Person.ransack(s: "user_email asc")

    expect(query.result.to_a).to eq [another_person, person]
    expect(query.result.to_sql).to include "`users`.`email` asc"
  end

  it "works with sub models" do
    query = User.ransack(organization_name_cont: "Test")
    expect(query.result.to_a).to eq [user]
  end

  it "works recursively with sub models" do
    query = Person.ransack(user_organization_name_cont: "Test")
    expect(query.result.to_a).to eq [person]
  end

  it "ignores empty contains" do
    query = Person.ransack(user_organization_name_cont: "")
    expect(query.result.to_sql).to eq "SELECT `persons`.* FROM `persons`"
  end

  it "ignores unknown parameters and doesn't raise exceptions" do
    Person.ransack(custom_something: "Test").result
  end
end
