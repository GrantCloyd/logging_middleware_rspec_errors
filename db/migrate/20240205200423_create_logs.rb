class CreateLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :logs do |t|
      t.string :request
      t.string :headers
      t.string :url, null: false
      t.string :response

      t.timestamps
    end
  end
end
