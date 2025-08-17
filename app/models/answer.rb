class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :survey_submission

  validates :response, presence: true
end
