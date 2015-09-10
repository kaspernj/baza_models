require "spec_helper"

describe BazaModels::Model::HasOneRelations do
  include DatabaseHelper

  let!(:user) { User.create!(email: "test@example.com", organization: organization) }
  let(:user_passport) { UserPassport.create(user: user) }
  let(:person) { Person.create!(user: user) }
  let(:role_user) { Role.create!(user: user, role: "user") }
  let!(:organization) { Organization.create!(name: "Test") }

  it "has one thorugh" do
    person
    expect(user.organization).to eq organization
    expect(user.person).to eq person
    expect(role_user.organization).to eq organization
  end

  context 'destroy' do
    before do
      user.save!
    end

    it 'restricts through has_one' do
      person
      expect { user.destroy! }.to raise_error(BazaModels::Errors::InvalidRecord)
    end

    it 'destroys through has_one' do
      user_passport
      user.destroy!
      expect { user_passport.reload }.to raise_error(BazaModels::Errors::RecordNotFound)
    end
  end
end
