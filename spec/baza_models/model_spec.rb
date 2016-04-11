require "spec_helper"

describe "BazaModels::Model" do
  include DatabaseHelper

  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  describe "#email" do
    it "returns set attributes" do
      expect(user.email).to eq "test@example.com"
    end

    it "returns nil for attributes that hasn't been set" do
      user = User.new
      expect(user.email).to eq nil
    end
  end

  it "#id #to_param" do
    expect(user.id).to eq nil
    expect(user.to_param).to eq nil
    user.save!
    expect(user.id).to_not eq nil
    expect(user.to_param).to_not eq nil
    expect(user.to_param).to eq user.id.to_s
  end

  it "#destroy_all" do
    5.times do |n|
      User.create! email: "user#{n}@example.com"
    end

    expect(User.count).to eq 5
    User.destroy_all
    expect(User.count).to eq 0
  end

  it "#email=" do
    user.email = "newemail@example.com"
    expect(user.email).to eq "newemail@example.com"
  end

  it "#email_was" do
    user.save!
    user.email = "newemail@example.com"
    expect(user.email_was).to eq "test@example.com"
  end

  it "#changes" do
    user.email = "newemail@example.com"
    expect(user.changes).to eq email: "newemail@example.com"
  end

  describe "#save" do
    it "inserts a new record when new" do
      expect(user.new_record?).to eq true
      user.save!
      expect(user.id).to eq 1
      expect(user.new_record?).to eq false
    end
  end

  it "#update_attributes" do
    user.save!
    expect(user.update_attributes(email: "newemail@example.com")).to eq true
    expect(user.email).to eq "newemail@example.com"
  end

  it "#before_save, #after_save" do
    expect(user.before_save_called).to eq nil
    expect(user.after_save_called).to eq nil
    expect(user.before_update_called).to eq nil
    expect(user.after_update_called).to eq nil
    user.save!
    expect(user.before_save_called).to eq 1
    expect(user.after_save_called).to eq 1
    expect(user.before_update_called).to eq nil
    expect(user.after_update_called).to eq nil
    user.save!
    expect(user.before_save_called).to eq 2
    expect(user.after_save_called).to eq 2
    expect(user.before_update_called).to eq 1
    expect(user.after_update_called).to eq 1
  end

  it "#before_create, #after_create" do
    expect(user.before_create_called).to eq nil
    expect(user.after_create_called).to eq nil
    user.save!
    expect(user.before_create_called).to eq 1
    expect(user.after_create_called).to eq 1
    user.save!
    expect(user.before_create_called).to eq 1
    expect(user.after_create_called).to eq 1
  end

  it "#before_destroy, #after_destroy" do
    user.save!
    expect(user.before_destroy_called).to eq nil
    expect(user.after_destroy_called).to eq nil
    user.destroy!
    expect(user.before_destroy_called).to eq 1
    expect(user.after_destroy_called).to eq 1
  end

  it "#after_initialize" do
    expect(user.instance_variable_get(:@after_initialize_called)).to eq 1
  end

  it "#after_find" do
    user.save!

    user_found = User.find(user.id)
    expect(user_found.instance_variable_get(:@after_find_called)).to eq 1
    expect(user.instance_variable_get(:@after_find_called)).to eq nil
  end

  it "can use callbacks as blocks" do
    expect(user.before_save_block_called).to eq nil
    user.save!
    expect(user.before_save_block_called).to eq 1
    user.save!
    expect(user.before_save_block_called).to eq 2
  end

  it "has array accessors" do
    expect(user[:email]).to eq "test@example.com"
    user[:email] = "new@example.com"
    expect(user[:email]).to eq "new@example.com"

    user.write_attribute(:email, "new2@example.com")
    expect(user.read_attribute(:email)).to eq "new2@example.com"
  end

  it "#to_key" do
    expect(user.to_key).to eq nil
    user.save!
    expect(user.to_key).to eq [1]
  end

  it "#changed?" do
    expect(user.changed?).to eq true
    user.save!
    expect(user.changed?).to eq false
    user.email = "new@example.com"
    expect(user.changed?).to eq true
    user.save!
    expect(user.changed?).to eq false
  end

  it "#each" do
    user.save!
    count = 0
    User.each do |user|
      expect(user).to eq user
      count += 1
    end

    expect(count).to eq 1
  end

  it "#attribute_names" do
    expect(User.attribute_names).to eq %w(id organization_id email email_confirmation created_at updated_at admin)
  end

  it "#columns" do
    id_column = User.columns.find { |column| column.name == "id" }

    expect(id_column.name).to eq "id"
    expect(id_column.type).to eq :integer
  end

  it "#columns_hash" do
    columns_hash = User.columns_hash

    id_column = columns_hash["id"]

    expect(id_column.type).to eq :integer
    expect(id_column.name).to eq "id"
    expect(id_column.null).to eq true
    expect(id_column.sql_type).to eq "int"

    email_column = columns_hash["email"]

    expect(email_column.type).to eq :string
    expect(email_column.name).to eq "email"
    expect(email_column.sql_type).to eq "varchar(255)"

    admin_column = columns_hash["admin"]

    expect(admin_column.type).to eq :boolean
    expect(admin_column.name).to eq "admin"
    expect(admin_column.sql_type).to eq "tinyint"
  end

  it "#reflections" do
    reflections = User.reflections

    person_reflection = reflections.values.find { |reflection| reflection.name == :person }
    expect(person_reflection.name).to eq :person
    expect(person_reflection.class_name).to eq "Person"
    expect(person_reflection.foreign_key).to eq "user_id"
    expect(person_reflection.klass).to eq Person
    expect(person_reflection.collection?).to eq false
  end

  it "doesnt care if initialized data has keys as strings" do
    user = User.new("email" => "test@example.com")
    expect(user.email).to eq "test@example.com"
  end
end
