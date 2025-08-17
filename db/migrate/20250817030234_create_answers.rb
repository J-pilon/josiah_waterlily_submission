class CreateAnswers < ActiveRecord::Migration[7.1]
  def change
    create_table :answers do |t|
      t.string :response, null: false
      t.references :question, null: false, foreign_key: true
      t.references :survey_submission, null: false, foreign_key: true

      t.timestamps
    end
  end
end
