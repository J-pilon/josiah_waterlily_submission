class CreateSurveySubmissions < ActiveRecord::Migration[7.1]
  def change
    create_table :survey_submissions do |t|
      t.references :survey, null: false, foreign_key: true

      t.timestamps
    end
  end
end
