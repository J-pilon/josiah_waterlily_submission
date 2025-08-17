class CreateQuestions < ActiveRecord::Migration[7.1]
  def change
    create_table :questions do |t|
      t.string :title, null: false
      t.string :description, null: false
      t.references :survey, null: false

      t.timestamps
    end
  end
end
