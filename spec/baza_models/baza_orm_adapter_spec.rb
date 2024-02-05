require "spec_helper"

describe BazaModels::BazaOrmAdapter do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }

  it "#get" do
    user.save!
    expect(User.to_adapter.get([1])).to eq user
    expect(User.to_adapter.get(1)).to eq user
    expect(User.to_adapter.get(5)).to be_nil
  end

  it "#get!" do
    user.save!
    expect(User.to_adapter.get!([1])).to eq user
    expect(User.to_adapter.get!(1)).to eq user

    expect do
      User.to_adapter.get!(5)
    end.to raise_error(BazaModels::Errors::RecordNotFound)
  end

  it "#create!" do
    expect { User.to_adapter.create!(email: "test@example.com") }.to change(User, :count).by(1)
  end

  it "#destroy" do
    user.save!

    expect do
      expect(User.to_adapter.destroy(user)).to be true
    end.to change(User, :count).by(-1)

    expect { user.reload }.to raise_error(BazaModels::Errors::RecordNotFound)
  end

  it "#find_first" do
    user.save!
    expect(User.to_adapter.find_first(id: 1)).to eq user
  end

  it "#find_all" do
    user.save!
    expect(User.to_adapter.find_all(id: 1).to_a).to eq [user]
  end

  it "#column_names" do
    expect(User.to_adapter.column_names).to eq %w[id organization_id email email_confirmation created_at updated_at admin]
  end
end
