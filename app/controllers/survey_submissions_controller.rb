class SurveySubmissionsController < ApplicationController
  def show
    @survey_submission = SurveySubmission.find(params[:id])
  end

  def new
    @survey = Survey.first
    @survey_submission = @survey.survey_submissions.build
    @survey.questions.each do |q|
      @survey_submission.answers.build(question: q)
    end
  end

  def create
    @survey_submission = SurveySubmission.new(survey_submission_params)

    if @survey_submission.save
      redirect_to @survey_submission, notice: 'Survey submission was successfully created.'
    else
      @survey = @survey_submission.survey
      render :new, status: :unprocessable_content
    end
  end

  private

  def survey_submission_params
    params.require(:survey_submission).permit(
      :survey_id,
      answers_attributes: [:id, :response, :question_id, :_destroy]
    )
  end
end
