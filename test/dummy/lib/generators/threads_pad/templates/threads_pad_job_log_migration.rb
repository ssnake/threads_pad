class CreateThreadsPadJobLogs < ActiveRecord::Migration
  def change
    create_table :threads_pad_job_logs do |t|
		t.integer :job_reflection_id
		t.integer :level
		t.text :msg
		t.index :job_reflection_id
    end
  end
end