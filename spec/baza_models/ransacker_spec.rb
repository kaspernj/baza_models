require "spec_helper"

describe BazaModels::Query do
  include DatabaseHelper

  let!(:organization) { Organization.create!(id: 1, name: "Test organization") }
  let!(:user) { User.create!(id: 1, organization: organization, email: "test@example.com") }
  let!(:another_user) { User.create!(id: 2, organization: nil, email: "another_user@example.com") }

  it "eq" do
    expect(User.ransack(id_eq: 1).result.to_a).to eq [user]
  end

  it "cont" do
    expect(User.ransack(email_cont: "test").result.to_a).to eq [user]
  end

  it "s" do
    query = User.ransack(s: "email asc")

    expect(query.result.to_a).to eq [another_user, user]
    expect(query.result.to_sql).to eq "SELECT `users`.* FROM `users` ORDER BY `email` asc"
  end

  it "works with sub models" do
    query = User.ransack(organization_name_cont: "Test")

    expect(query.result.to_a).to eq [user]
  end
end
