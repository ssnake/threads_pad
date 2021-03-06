class CreateThreadsPadJobLogs < ActiveRecord::Migration
  def up
    create_table :threads_pad_job_logs do |t|
		t.integer :job_reflection_id
		t.integer :level
		t.text :msg
		t.datetime "created_at",          null: false
		t.index :job_reflection_id
             t.integer :group_id
    end
    
  end
  def down
  	drop_table :threads_pad_job_logs
  
  end
end