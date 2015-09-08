require "spec_helper"

describe BazaModels::Query::Not do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }

  it "#not" do
    user.save!

    expect(User.where.not(email: "kasper@example.com").to_a).to eq [user]
    expect(User.where.not(email: "test@example.com").to_a).to eq []
    expect(User.where.not(email: ["kasper@example.com"]).to_a).to eq [user]
    expect(User.where.not(email: ["test@example.com"]).to_a).to eq []
  end
end
