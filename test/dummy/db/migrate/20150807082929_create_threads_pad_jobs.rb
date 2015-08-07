class CreateThreadsPadJobs < ActiveRecord::Migration
  def change
    create_table :threads_pad_jobs do |t|
		t.boolean :terminated
		t.boolean :done
		t.string :result
		t.integer :group_id, :integer
		t.integer :max, :integer
		t.integer :current, :integer
		t.integer :min, :integer
		t.boolean :started
		t.boolean :destroy_on_finish
		t.index :group_id
    end
  end
end