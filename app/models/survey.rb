class Survey < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :survey_submissions, dependent: :destroy
end
