class CreateThreadsPadJobTable < ActiveRecord::Migration
  def change
    create_table :threads_pad_jobs do |t|
      t.boolean :terminated
      t.boolean :done
      t.string :result
    end
  end
end
