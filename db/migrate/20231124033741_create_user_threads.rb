class CreateUserThreads < ActiveRecord::Migration[7.1]
  def change
    create_table :user_threads, id: false do |t|
      t.string :user_id, null: false, primary_key: true
      t.string :thread_id, null: false

      t.timestamps
    end

    add_index :user_threads, :thread_id, unique: true
  end
end
