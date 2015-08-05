class AddFeildsToThreadsPadJob < ActiveRecord::Migration
  def change
  	add_column :threads_pad_jobs, :group_id, :integer
  	add_column :threads_pad_jobs, :max, :integer
  	add_column :threads_pad_jobs, :current, :integer
  	add_column :threads_pad_jobs, :min, :integer

  	add_index :threads_pad_jobs, :group_id

  end
end
