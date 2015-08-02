require "spec_helper"

describe "BazaModels::Model" do
  let(:db) { @db }
  let(:user) { User.new(email: "test@example.com") }
  let(:role_user) { Role.new(user: user, role: "user") }
  let(:role_admin) { Role.new(user: user, role: "administrator") }

  before do
    @count ||= 0
    @count += 1

    require "tempfile"
    require "baza"
    require "sqlite3"

    path = Tempfile.new("baza_test").path
    File.unlink(path) if File.exists?(path)

    @db = Baza::Db.new(type: :sqlite3, path: path, debug: false)
    BazaModels.primary_db = @db

    @db.tables.create(:users, {
      columns: [
        {name: :id, type: :int, primarykey: true, autoincr: true},
        {name: :email, type: :varchar}
      ],
      indexes: [
        :email
      ]
    })

    @db.tables.create(:roles, {
      columns: [
        {name: :id, type: :int, primarykey: true, autoincr: true},
        {name: :user_id, type: :int},
        {name: :role, type: :varchar}
      ],
      indexes: [
        :user_id
      ]
    })

    require "test_classes/user"
    require "test_classes/role"
  end

  after do
    BazaModels.primary_db = nil

    @db.close
    path = db.args[:path]
    File.unlink(path)
    Thread.current[:baza] = nil
    @db = nil
  end

  it "#email" do
    expect(user.email).to eq "test@example.com"
  end

  it "#email=" do
    user.email = "newemail@example.com"
    expect(user.email).to eq "newemail@example.com"
  end

  it "#email_was" do
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
      user.save
      expect(user.id).to eq 1
      expect(user.new_record?).to eq false
    end
  end

  describe "#valid?" do
    it "returns true when valid" do
      expect(user.valid?).to eq true
    end

    it "returns false when invalid" do
      user.email = " "
      expect(user.valid?).to eq false
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
    user.save!
    expect(user.before_save_called).to eq 1
    expect(user.after_save_called).to eq 1
    user.save!
    expect(user.before_save_called).to eq 2
    expect(user.after_save_called).to eq 2
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

  it "#before_validation, #after_validation" do
    expect(user.before_validation_called).to eq nil
    expect(user.after_validation_called).to eq nil
    user.valid?
    expect(user.before_validation_called).to eq 1
    expect(user.after_validation_called).to eq 1
  end

  it "#before_validation_on_create, #after_validation_on_create, #before_validation_on_update, #after_validation_on_update" do
    expect(user.before_validation_on_create_called).to eq nil
    expect(user.after_validation_on_create_called).to eq nil

    expect(user.before_validation_on_update_called).to eq nil
    expect(user.after_validation_on_update_called).to eq nil

    user.save!

    expect(user.before_validation_on_create_called).to eq 1
    expect(user.after_validation_on_create_called).to eq 1

    expect(user.before_validation_on_update_called).to eq nil
    expect(user.after_validation_on_update_called).to eq nil

    user.update_attributes!(email: "newemail@example.com")

    expect(user.before_validation_on_create_called).to eq 1
    expect(user.after_validation_on_create_called).to eq 1

    expect(user.before_validation_on_update_called).to eq 1
    expect(user.after_validation_on_update_called).to eq 1
  end

  it "#find" do
    user.save!
    user_found = User.find(user.id)
    expect(user_found.email).to eq "test@example.com"
  end

  it "#find_by" do
    user.save!
    user_found = User.find_by(id: 1, email: "test@example.com")
    expect(user_found.email).to eq "test@example.com"
  end

  context "#where" do
    before do
      user.save!
    end

    it 'supports hashes' do
      query = User.where(email: "test@example.com")
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` WHERE `users`.`email` = 'test@example.com'"
      expect(query.to_a).to eq [user]
    end

    it 'supports strings' do
      query = User.where("email = 'test@example.com'")
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` WHERE email = 'test@example.com'"
      expect(query.to_a).to eq [user]
    end
  end

  context "relationships" do
    before do
      user.save!
      role_user.save!
      role_admin.save!
    end

    it "#belongs_to" do
      expect(role_user.user).to eq user
    end

    describe "#has_many" do
      it "returns whole collections without arguments" do
        expect(user.roles.to_a).to eq [role_user, role_admin]
      end

      it "supports class_name and proc-arguments" do
        expect(user.admin_roles.to_a).to eq [role_admin]
        expect(user.admin_roles.to_sql).to eq "SELECT `roles`.* FROM `roles` WHERE `roles`.`user_id` = '#{user.id}' AND `roles`.`role` = 'administrator'"
      end
    end
  end

  context 'scopes' do
    before do
      user.save!
      role_user.save!
      role_admin.save!
    end

    it 'works with where' do
      expect(Role.admin_roles.to_a).to eq [role_admin]
    end

    it 'joins as well' do
      expect(User.admin_roles.to_a).to eq [user]
    end
  end

  context '#joins' do
    before do
      user.save!
      role_admin.save!
    end

    it 'joins with symbols and relationships' do
      query = User.joins(:roles).where(roles: {role: 'administrator'})
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` INNER JOIN `roles` ON `roles`.`user_id` = `users`.`id` WHERE `roles`.`role` = 'administrator'"
      expect(query.to_a).to eq [user]
    end

    it 'joins with strings' do
      query = User.joins('LEFT JOIN roles ON roles.user_id = users.id').where(roles: {role: 'administrator'})
      expect(query.to_sql).to eq "SELECT `users`.* FROM `users` LEFT JOIN roles ON roles.user_id = users.id WHERE `roles`.`role` = 'administrator'"
      expect(query.to_a).to eq [user]
    end
  end

  context '#includes' do
    before do
      user.save!
      role_admin.save!
    end

    it 'autoloads via includes on has_many relations' do
      query = User.includes(:roles).to_a
      user = query.first

      expect(user.autoloads.fetch(:roles)).to eq [role_admin]
      expect(user.roles.__send__(:any_mods?)).to eq false
      expect(user.roles.__send__(:any_wheres_other_than_relation?)).to eq false
      expect(user.roles.__send__(:autoloaded_on_previous_model?)).to eq true
      expect(user.roles.to_enum).to eq [role_admin]
    end

    it 'autoloads via includes on belongs_to relations' do
      query = Role.includes(:user).to_a
      role = query.first

      allow(role.autoloads).to receive(:[]).and_call_original
      expect(role.user).to eq user
      expect(role.autoloads).to have_received(:[]).with(:user)
      expect(role.autoloads[:user]).to eq user
    end
  end

  context '#destroy' do
    before do
      user.save!
    end

    it 'destroyes through has_many' do
      role_user.save!
      user.destroy!
      expect { user.reload }.to raise_error(BazaModels::Errors::RecordNotFound)
      expect { role_user.reload }.to raise_error(BazaModels::Errors::RecordNotFound)
    end

    it 'restricts through has_many' do
      role_admin.save!
      expect { user.destroy! }.to raise_error(BazaModels::Errors::InvalidRecord)
    end
  end
end
