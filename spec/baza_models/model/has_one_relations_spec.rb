require "spec_helper"

describe BazaModels::Model::HasOneRelations do
  include DatabaseHelper

  let!(:user) { User.create!(email: "test@example.com", organization: organization) }
  let!(:person) { Person.create!(user: user) }
  let(:role_user) { Role.create!(user: user, role: "user") }
  let!(:organization) { Organization.create!(name: "Test") }

  it "works" do
    expect(user.organization).to eq organization
  end

  it "has one through" do
    expect(role_user.organization).to eq organization
  end

  context 'destroy' do
    before do
      user.save!
    end

    it 'restricts through has_one' do
      expect { user.destroy! }.to raise_error(BazaModels::Errors::InvalidRecord)
    end
  end
end
