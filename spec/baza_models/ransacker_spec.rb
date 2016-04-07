require "spec_helper"

describe BazaModels::Query do
  include DatabaseHelper

  let!(:organization) { Organization.create!(id: 1, name: "Test organization") }
  let!(:person) { Person.create!(id: 1, user: user) }
  let!(:user) { User.create!(id: 1, organization: organization, email: "test@example.com") }
  let!(:another_user) { User.create!(id: 2, organization: nil, email: "another_user@example.com") }
  let!(:another_person) { Person.create!(id: 2, user: another_user) }

  it "eq" do
    expect(User.ransack(id_eq: 1).result.to_a).to eq [user]
  end

  it "cont" do
    expect(User.ransack(email_cont: "test").result.to_a).to eq [user]
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
end
