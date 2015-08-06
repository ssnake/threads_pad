require 'rails/generators/active_record'

class ThreadsPadGenerator < ActiveRecord::Generators::Base
  source_root File.expand_path('../templates', __FILE__)
  def generate_migration
    migration_template "threads_pad_job_migration.rb", "db/migrate/create_threads_pad_jobs.rb"
  end
end
