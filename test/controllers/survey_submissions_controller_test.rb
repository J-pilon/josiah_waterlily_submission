require "test_helper"

class SurveySubmissionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @survey = surveys(:one)
    @question = questions(:one)
    @survey_submission = survey_submissions(:one)
    @answer = answers(:one)
  end

  test "should get show" do
    get survey_submission_path(@survey_submission)
    assert_response :success
    assert_select "h1", "Survey Submission"
    assert_select "h2", @survey.title
  end

  test "should get new" do
    get new_survey_submission_path
    assert_response :success
    assert_select "h1", @survey.title
    assert_select "form[action='#{survey_submissions_path}']"
    assert_select "input[name='survey_submission[survey_id]']"
    assert_select "textarea[name*='[response]']", count: @survey.questions.count
  end

  test "should create survey submission with valid params" do
    assert_difference('SurveySubmission.count') do
      assert_difference('Answer.count', @survey.questions.count) do
        post survey_submissions_path, params: {
          survey_submission: {
            survey_id: @survey.id,
            answers_attributes: {
              "0" => { question_id: @survey.questions.first.id, response: "Very Satisfied" },
            }
          }
        }
      end
    end

    assert_redirected_to survey_submission_path(SurveySubmission.last)
    assert_equal 'Survey submission was successfully created.', flash[:notice]
  end

  test "should create survey submission with all questions answered" do
    all_questions = @survey.questions

    assert_difference('SurveySubmission.count') do
      assert_difference('Answer.count', all_questions.count) do
        post survey_submissions_path, params: {
          survey_submission: {
            survey_id: @survey.id,
            answers_attributes: all_questions.map.with_index do |question, index|
              [index.to_s, { question_id: question.id, response: "Response #{index + 1}" }]
            end.to_h
          }
        }
      end
    end

    submission = SurveySubmission.last
    assert_equal all_questions.count, submission.answers.count
    assert_redirected_to survey_submission_url(submission)
  end

  test "should not create survey submission with missing answers" do
    @survey.questions.build(title: "title", description: "description")
    @survey.save

    assert_no_difference('SurveySubmission.count') do
      post survey_submissions_path, params: {
        survey_submission: {
          survey_id: @survey.id,
          answers_attributes: {
            "0" => { question_id: @survey.questions.first.id, response: "Very Satisfied" }
            # Missing answer for second question
          }
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "should not create survey submission with blank responses" do
    assert_no_difference('SurveySubmission.count') do
      post survey_submissions_path, params: {
        survey_submission: {
          survey_id: @survey.id,
          answers_attributes: {
            "0" => { question_id: @survey.questions.first.id, response: "" },
            "1" => { question_id: @survey.questions.last.id, response: "Good" }
          }
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "should not create survey submission with nil responses" do
    assert_no_difference('SurveySubmission.count') do
      post survey_submissions_path, params: {
        survey_submission: {
          survey_id: @survey.id,
          answers_attributes: {
            "0" => { question_id: @survey.questions.first.id, response: nil },
            "1" => { question_id: @survey.questions.last.id, response: "Good" }
          }
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "should not create survey submission with invalid question_id" do
    assert_no_difference('SurveySubmission.count') do
      post survey_submissions_path, params: {
        survey_submission: {
          survey_id: @survey.id,
          answers_attributes: {
            "0" => { question_id: 99999, response: "Test Response" }
          }
        }
      }
    end

    assert_response :unprocessable_content
  end

  test "should rebuild answers when validation fails" do
    post survey_submissions_path, params: {
      survey_submission: {
        survey_id: @survey.id,
        answers_attributes: {
          "0" => { question_id: @survey.questions.first.id, response: "" }
        }
      }
    }

    assert_response :unprocessable_content
    assert_select "form[action='#{survey_submissions_path}']"
    assert_select "textarea[name*='[response]']", count: @survey.questions.count
  end

  test "should show survey submission with associated data" do
    get survey_submission_path(@survey_submission)

    assert_response :success
    assert_select "h2", @survey.title
    assert_select "p", @survey.description
    assert_select ".bg-white", count: @survey_submission.answers.count + 1 # +1 for survey info card
  end

  test "should display all questions and answers" do
    get survey_submission_path(@survey_submission)

    @survey_submission.answers.each do |answer|
      assert_select "h3", text: /Question \d+: #{answer.question.title}/
      assert_select "p", text: answer.question.description
      if answer.response.present?
        assert_select "span", text: answer.response
      end
    end
  end

  # test "should handle survey submission with no answers gracefully" do
  #   empty_submission = @survey.survey_submissions.create!

  #   get survey_submission_path(empty_submission)
  #   assert_response :success
  #   assert_select "h1", "Survey Submission"
  # end

  # test "should handle survey submission with missing question gracefully" do
  #   # Create a submission with an answer that references a non-existent question
  #   submission = @survey.survey_submissions.create!
  #   submission.answers.create!(question_id: 99999, response: "Test", survey_submission: submission)

  #   get survey_submission_path(submission)
  #   assert_response :success
  # end

  test "should use proper HTTP methods" do
    # GET for show
    get survey_submission_path(@survey_submission)
    assert_response :success

    # GET for new
    get new_survey_submission_path
    assert_response :success

    # POST survey_submissions_path create
    post survey_submissions_path, params: {
      survey_submission: {
        survey_id: @survey.id,
        answers_attributes: {
          "0" => { question_id: @question.id, response: "Test Response" }
        }
      }
    }
    assert_response :redirect
  end

  # test "should handle malformed parameters gracefully" do
  #   assert_no_difference('SurveySubmission.count') do
  #     post survey_submissions_path, params: {
  #       survey_id: @survey.id,
  #       survey_submission: { answers_attributes: {}}
  #     }
  #   end

  #   assert_response :unprocessable_content
  # end

  test "should handle empty parameters gracefully" do
    assert_no_difference('SurveySubmission.count') do
      post survey_submissions_path, params: { survey_submission: { survey_id: @survey.id }}
    end

    assert_response :unprocessable_content
  end

  test "should create survey submission with special characters in responses" do
    special_response = "Response with symbols: !@#$%^&*() <>&\"'"

    assert_difference('SurveySubmission.count') do
      post survey_submissions_path, params: {
        survey_submission: {
          survey_id: @survey.id,
          answers_attributes: {
            "0" => { question_id: @question.id, response: special_response }
          }
        }
      }
    end

    submission = SurveySubmission.last
    assert_equal special_response, submission.answers.first.response
  end

  test "should create survey submission with long responses" do
    long_response = "A" * 500

    assert_difference('SurveySubmission.count') do
      post survey_submissions_path, params: {
        survey_submission: {
          survey_id: @survey.id,
          answers_attributes: {
            "0" => { question_id: @question.id, response: long_response }
          }
        }
      }
    end

    submission = SurveySubmission.last
    assert_equal long_response, submission.answers.first.response
  end
end
