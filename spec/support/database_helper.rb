require "tempfile"
require "baza"

if RUBY_PLATFORM == "java"
  require "jdbc/sqlite3"
  Jdbc::SQLite3.load_driver
else
  require "sqlite3"
end

module DatabaseHelper
  def self.included(base)
    base.instance_eval do
      let(:db) { @db }

      before do
        init_database_connection
        init_database_structure

        User.init_model(force: true)
      end

      after do
        BazaModels.primary_db = nil

        @db.close
        path = db.args.fetch(:path)
        File.unlink(path) if File.exist?(path)
        Thread.current[:baza] = nil
        @db = nil
      end
    end
  end

  def init_database_connection
    tempfile = Tempfile.new(["baza_test", ".sqlite3"])
    path = tempfile.path
    tempfile.close!

    @db = Baza::Db.new(type: :sqlite3, path: path, index_append_table_name: true, debug: false)
    BazaModels.primary_db = @db
  end

  def init_database_structure
    @db.tables.create(
      :users,
      columns: [
        {name: :id, type: :int, primarykey: true, autoincr: true},
        {name: :organization_id, type: :int},
        {name: :email, type: :varchar},
        {name: :email_confirmation, type: :varchar},
        {name: :created_at, type: :datetime},
        {name: :updated_at, type: :datetime},
        {name: :admin, type: :tinyint}
      ],
      indexes: [:organization_id, :email]
    )

    @db.tables.create(
      :user_passports,
      columns: [
        {name: :id, type: :int, primarykey: true, autoincr: true},
        {name: :user_id, type: :int},
        {name: :code, type: :varchar}
      ],
      indexes: [
        :user_id
      ]
    )

    @db.tables.create(
      :persons,
      columns: [
        {name: :id, type: :int, primarykey: true, autoincr: true},
        {name: :user_id, type: :int}
      ],
      indexes: [:user_id]
    )

    @db.tables.create(
      :roles,
      columns: [
        {name: :id, type: :int, primarykey: true, autoincr: true},
        {name: :user_id, type: :int},
        {name: :role, type: :varchar},
        {name: :created_at, type: :datetime},
        {name: :updated_at, type: :datetime}
      ],
      indexes: [:user_id]
    )

    @db.tables.create(
      :organizations,
      columns: [
        {name: :id, type: :int, primarykey: true, autoincr: true},
        {name: :name, type: :varchar}
      ]
    )
  end
end
