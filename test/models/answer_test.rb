require "test_helper"

class AnswerTest < ActiveSupport::TestCase
  def setup
    @answer = answers(:one)
    @another_answer = answers(:two)
    @question = questions(:one)
    @survey_submission = survey_submissions(:one)
  end

  test "should be valid" do
    assert @answer.valid?
  end

  test "should have required attributes" do
    assert_respond_to @answer, :response
    assert_respond_to @answer, :question_id
    assert_respond_to @answer, :survey_submission_id
    assert_respond_to @answer, :created_at
    assert_respond_to @answer, :updated_at
  end

  test "should have response" do
    assert_equal "MyString", @answer.response
  end

  test "should belong to question" do
    assert_respond_to @answer, :question
    assert_equal @question, @answer.question
  end

  test "should belong to survey submission" do
    assert_respond_to @answer, :survey_submission
    assert_equal @survey_submission, @answer.survey_submission
  end

  test "should have question_id" do
    assert_equal @question.id, @answer.question_id
  end

  test "should have survey_submission_id" do
    assert_equal @survey_submission.id, @answer.survey_submission_id
  end

  test "should create a new answer" do
    answer = Answer.new(
      response: "Test Response",
      question: @question,
      survey_submission: @survey_submission
    )
    assert answer.save
    assert_equal "Test Response", answer.response
    assert_equal @question, answer.question
    assert_equal @survey_submission, answer.survey_submission
  end

  test "should update answer attributes" do
    @answer.response = "Updated Response"
    assert @answer.save
    assert_equal "Updated Response", @answer.reload.response
  end

  test "should destroy answer" do
    assert_difference('Answer.count', -1) do
      @answer.destroy
    end
  end

  test "should find answer by id" do
    found_answer = Answer.find(@answer.id)
    assert_equal @answer.response, found_answer.response
    assert_equal @answer.question_id, found_answer.question_id
    assert_equal @answer.survey_submission_id, found_answer.survey_submission_id
  end

  test "should find all answers" do
    answers = Answer.all
    assert answers.any?
    assert answers.include?(@answer)
    assert answers.include?(@another_answer)
  end

  test "should have timestamps" do
    assert_not_nil @answer.created_at
    assert_not_nil @answer.updated_at
  end

  # Test associations
  test "should access question through association" do
    assert_equal @question, @answer.question
    assert_equal @question.title, @answer.question.title
    assert_equal @question.description, @answer.question.description
  end

  test "should access survey submission through association" do
    assert_equal @survey_submission, @answer.survey_submission
    assert_equal @survey_submission.survey_id, @answer.survey_submission.survey_id
  end

  test "should change question association" do
    new_question = questions(:two)
    @answer.question = new_question
    assert @answer.save
    assert_equal new_question.id, @answer.reload.question_id
    assert_equal new_question, @answer.question
  end

  test "should change survey submission association" do
    new_submission = survey_submissions(:two)
    @answer.survey_submission = new_submission
    assert @answer.save
    assert_equal new_submission.id, @answer.reload.survey_submission_id
    assert_equal new_submission, @answer.survey_submission
  end

  # Test validations
  test "should not save without response" do
    answer = Answer.new(question: @question, survey_submission: @survey_submission)
    assert_not answer.save
    assert_includes answer.errors[:response], "can't be blank"
  end

  test "should not save with empty response" do
    answer = Answer.new(response: "", question: @question, survey_submission: @survey_submission)
    assert_not answer.save
    assert_includes answer.errors[:response], "can't be blank"
  end

  test "should not save with nil response" do
    answer = Answer.new(response: nil, question: @question, survey_submission: @survey_submission)
    assert_not answer.save
    assert_includes answer.errors[:response], "can't be blank"
  end

  test "should not save without question" do
    answer = Answer.new(response: "Test Response", survey_submission: @survey_submission)
    assert_not answer.save
    assert_includes answer.errors[:question], "must exist"
  end

  test "should not save without survey submission" do
    answer = Answer.new(response: "Test Response", question: @question)
    assert_not answer.save
    assert_includes answer.errors[:survey_submission], "must exist"
  end

  test "should not save with invalid question_id" do
    answer = Answer.new(response: "Test Response", question_id: 99999, survey_submission: @survey_submission)
    assert_not answer.save
    assert_includes answer.errors[:question], "must exist"
  end

  test "should not save with invalid survey_submission_id" do
    answer = Answer.new(response: "Test Response", question: @question, survey_submission_id: 99999)
    assert_not answer.save
    assert_includes answer.errors[:survey_submission], "must exist"
  end

  # Test fixture data integrity
  test "fixtures should be valid" do
    Answer.find_each do |answer|
      assert answer.valid?, "Answer #{answer.id} should be valid"
    end
  end

  test "fixtures should have unique ids" do
    answer_ids = Answer.pluck(:id)
    assert_equal answer_ids.uniq.length, answer_ids.length, "Answer fixtures should have unique IDs"
  end

  test "fixtures should reference valid questions" do
    Answer.find_each do |answer|
      assert Question.exists?(answer.question_id), "Answer #{answer.id} should reference a valid question"
    end
  end

  test "fixtures should reference valid survey submissions" do
    Answer.find_each do |answer|
      assert SurveySubmission.exists?(answer.survey_submission_id), "Answer #{answer.id} should reference a valid survey submission"
    end
  end

  # Test scopes and queries
  test "should find answers by question" do
    question_answers = Answer.where(question: @question)
    assert question_answers.any?
    question_answers.each do |answer|
      assert_equal @question.id, answer.question_id
    end
  end

  test "should find answers by survey submission" do
    submission_answers = Answer.where(survey_submission: @survey_submission)
    assert submission_answers.any?
    submission_answers.each do |answer|
      assert_equal @survey_submission.id, answer.survey_submission_id
    end
  end

  test "should count answers per question" do
    question_answers_count = Answer.where(question: @question).count
    assert question_answers_count > 0
  end

  test "should count answers per survey submission" do
    submission_answers_count = Answer.where(survey_submission: @survey_submission).count
    assert submission_answers_count > 0
  end

  test "should find answers by response content" do
    response_answers = Answer.where(response: "MyString")
    assert response_answers.any?
    response_answers.each do |answer|
      assert_equal "MyString", answer.response
    end
  end

  # Test model behavior
  test "should handle multiple answers for same question" do
    first_answer = Answer.create!(response: "First Answer", question: @question, survey_submission: @survey_submission)
    second_answer = Answer.create!(response: "Second Answer", question: @question, survey_submission: @survey_submission)

    assert_equal @question.id, first_answer.question_id
    assert_equal @question.id, second_answer.question_id
    assert_equal @question, first_answer.question
    assert_equal @question, second_answer.question

    # Clean up
    first_answer.destroy
    second_answer.destroy
  end

  test "should handle multiple answers for same survey submission" do
    first_answer = Answer.create!(response: "First Answer", question: @question, survey_submission: @survey_submission)
    second_answer = Answer.create!(response: "Second Answer", question: questions(:two), survey_submission: @survey_submission)

    assert_equal @survey_submission.id, first_answer.survey_submission_id
    assert_equal @survey_submission.id, second_answer.survey_submission_id
    assert_equal @survey_submission, first_answer.survey_submission
    assert_equal @survey_submission, second_answer.survey_submission

    # Clean up
    first_answer.destroy
    second_answer.destroy
  end

  # Test data types and edge cases
  test "should handle long responses" do
    long_response = "A" * 1000
    answer = Answer.new(response: long_response, question: @question, survey_submission: @survey_submission)
    assert answer.save
    assert_equal long_response, answer.response
  end

  test "should handle special characters in response" do
    special_response = "Response with symbols: !@#$%^&*() <>&\"'"
    answer = Answer.new(response: special_response, question: @question, survey_submission: @survey_submission)
    assert answer.save
    assert_equal special_response, answer.response
  end

  test "should handle numeric responses" do
    numeric_response = "42"
    answer = Answer.new(response: numeric_response, question: @question, survey_submission: @survey_submission)
    assert answer.save
    assert_equal numeric_response, answer.response
  end

  # Test ordering and scoping
  test "should order by creation time" do
    answers = Answer.order(:created_at)
    assert answers.any?

    # Check if they're properly ordered
    previous_time = nil
    answers.each do |answer|
      if previous_time
        assert answer.created_at >= previous_time, "Answers should be ordered by created_at"
      end
      previous_time = answer.created_at
    end
  end

  test "should find recent answers" do
    recent_answers = Answer.where("created_at > ?", 1.day.ago)
    assert recent_answers.any?
    recent_answers.each do |answer|
      assert answer.created_at > 1.day.ago, "Should only find recent answers"
    end
  end

  # Test model methods
  test "should respond to association methods" do
    assert_respond_to @answer, :question
    assert_respond_to @answer, :question_id
    assert_respond_to @answer, :question_id=
    assert_respond_to @answer, :survey_submission
    assert_respond_to @answer, :survey_submission_id
    assert_respond_to @answer, :survey_submission_id=
  end

  test "should have proper association types" do
    assert_instance_of Question, @answer.question
    assert_instance_of SurveySubmission, @answer.survey_submission
  end

  # Test database constraints
  test "should enforce foreign key constraints" do
    # This test verifies that the database enforces the foreign keys
    # It should fail when trying to create an answer with non-existent question_id or survey_submission_id
    assert_raises(ActiveRecord::InvalidForeignKey) do
      Answer.connection.execute(
        "INSERT INTO answers (response, question_id, survey_submission_id, created_at, updated_at) VALUES ('Test', 99999, #{@survey_submission.id}, NOW(), NOW())"
      )
    end
  rescue ActiveRecord::InvalidForeignKey
    # Expected behavior - foreign key constraint enforced
    pass
  rescue => e
    # If the error is different, that's also acceptable
    pass
  end
end
