# Stolen from https://gist.github.com/schickling/6762581
# Thank you <3
require "yaml"
require "active_record"

namespace :db do
  db_config = YAML.safe_load(File.open("spec/config/database.yml"))

  def activerecord_below_5_2?
    ActiveRecord.version.release < Gem::Version.new("5.2.0")
  end

  desc "Migrate the database"
  task :migrate do
    ActiveRecord::Base.establish_connection(db_config)

    if activerecord_below_5_2?
      ActiveRecord::Migrator.migrate("spec/db/migrate")
    else
      ActiveRecord::MigrationContext.new("spec/db/migrate").migrate
    end

    Rake::Task["db:schema"].invoke
    puts "Database migrated."
  end

  desc "Create a db/schema.rb file that is portable against any supported DB"
  task :schema do
    ActiveRecord::Base.establish_connection(db_config)
    require "active_record/schema_dumper"
    filename = "spec/db/schema.rb"
    File.open(filename, "w:utf-8") do |file|
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
    end
  end
end

namespace :g do
  desc "Generate migration"
  task :migration do
    name      = ARGV[1] || raise("Specify name: rake g:migration name")
    timestamp = Time.now.strftime("%Y%m%d%H%M%S")
    folder    = "../spec/db/migrate"
    path      = File.expand_path("#{folder}/#{timestamp}_#{name}.rb", __FILE__)

    migration_class = name.split("_").map(&:capitalize).join

    File.open(path, "w") do |file|
      file.write <<-MIGRATION.strip_heredoc
        class #{migration_class} < ActiveRecord::Migration[5.2]
          def change
          end
        end
      MIGRATION
    end

    puts "Migration #{path} created"
    abort # needed stop other tasks
  end
end
