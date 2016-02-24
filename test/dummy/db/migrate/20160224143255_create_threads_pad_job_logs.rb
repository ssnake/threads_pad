class CreateThreadsPadJobLogs < ActiveRecord::Migration
  def up
    create_table :threads_pad_job_logs do |t|
		t.integer :job_reflection_id
		t.integer :level
		t.text :msg
		t.datetime "created_at",          null: false
		t.index :job_reflection_id
    end
    execute "CREATE SEQUENCE threads_pad_group_seq START 1"
  end
  def down
  	drop_table :threads_pad_job_logs
  	execute "DROP SEQUENCE threads_pad_group_seq"
  end
end