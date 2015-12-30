class BazaModels::TestDatabaseCleaner
  def self.clean
    BazaModels::TestDatabaseCleaner.new.truncate_all_tables
  end

  def initialize
    raise "Not in test-environment" unless Rails.env.test?

    @db = BazaModels.primary_db

    raise "No primary database on BazaModels?" unless @db

    truncate_all_tables
  end

  def truncate_all_tables
    @db.transaction do
      @db.tables.list do |table|
        table.truncate unless table.name == "baza_schema_migrations"
      end
    end
  end
end
