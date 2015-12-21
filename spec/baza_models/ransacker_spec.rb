require "spec_helper"

describe BazaModels::Query do
  include DatabaseHelper

  let!(:user) { User.create!(id: 1, email: "test@example.com") }

  it "eq" do
    expect(User.ransack(id_eq: 1).result.to_a).to eq [user]
  end

  it "cont" do
    expect(User.ransack(email_cont: "test").result.to_a).to eq [user]
  end
end
