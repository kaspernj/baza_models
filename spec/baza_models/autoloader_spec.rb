require "spec_helper"

describe BazaModels::Autoloader do
  include DatabaseHelper

  let(:organization) { Organization.new }
  let(:user) { User.new(email: "test@example.com", organization: organization) }
  let(:user_passport) { UserPassport.new(user: user) }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  before do
    organization.save!
    user.save!
    user_passport.save!
    role_admin.save!
  end

  it 'autoloads via includes on has_many relations' do
    query = User.includes(:roles).to_a
    user_from_query = query.first

    expect(user_from_query.autoloads.fetch(:roles)).to eq [role_admin]
    expect(user_from_query.roles.__send__(:any_mods?)).to eq false
    expect(user_from_query.roles.__send__(:any_wheres_other_than_relation?)).to eq false
    expect(user_from_query.roles.__send__(:autoloaded_on_previous_model?)).to eq true
    expect(user_from_query.roles.to_enum).to eq [role_admin]
  end

  it 'autoloads via includes on belongs_to relations' do
    query = Role.includes(:user).to_a
    role = query.first

    allow(role.autoloads).to receive(:[]).and_call_original
    expect(role.user).to eq user
    expect(role.autoloads).to have_received(:[]).with(:user)
    expect(role.autoloads[:user]).to eq user
  end

  it 'autoloads via includes on has_one relations' do
    query = User.includes(:user_passport).to_a
    user = query.first

    allow(user.autoloads).to receive(:[]).and_call_original
    expect(user.user_passport).to eq user_passport
    expect(user.autoloads).to have_received(:[]).with(:user_passport)
    expect(user.autoloads[:user_passport]).to eq user_passport
  end

  it 'autoloads sub models' do
    organizations = Organization.includes(users: :roles).to_a
    organization = organizations.first

    expect(organization.autoloads.fetch(:users)).to eq [user]

    expect(organization.users.to_a).to eq [user]
    org_user = organization.autoloads.fetch(:users).first
    expect(org_user.autoloads.fetch(:roles)).to eq [role_admin]

    org_user = organization.users.first
    expect(org_user.autoloads.fetch(:roles)).to eq [role_admin]
  end
end