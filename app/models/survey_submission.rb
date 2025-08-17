class SurveySubmission < ApplicationRecord
  belongs_to :survey
  has_many :answers, dependent: :destroy

  accepts_nested_attributes_for :answers, allow_destroy: true, reject_if: :all_blank

  validates :survey, presence: true
  validate :has_answers_for_all_questions

  private

  def has_answers_for_all_questions
    return unless survey.present?

    survey_question_ids = survey.questions.pluck(:id).sort
    submission_question_ids = answers.reject(&:marked_for_destruction?).map(&:question_id).compact.sort

    if survey_question_ids != submission_question_ids
      missing_questions = survey_question_ids - submission_question_ids
      errors.add(:base, "Must provide answers for all questions. Missing: #{missing_questions.join(', ')}")
    end
  end
end
