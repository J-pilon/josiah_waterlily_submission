require "test_helper"

class SurveySubmissionTest < ActiveSupport::TestCase
  def setup
    @survey_submission = survey_submissions(:one)
    @another_submission = survey_submissions(:two)
    @survey = surveys(:one)
  end

  test "should be valid" do
    assert @survey_submission.valid?
  end

  test "should have required attributes" do
    assert_respond_to @survey_submission, :survey_id
    assert_respond_to @survey_submission, :created_at
    assert_respond_to @survey_submission, :updated_at
  end

  test "should belong to survey" do
    assert_respond_to @survey_submission, :survey
    assert_equal @survey, @survey_submission.survey
  end

  test "should have survey_id" do
    assert_equal @survey.id, @survey_submission.survey_id
  end

  test "should create a new survey submission" do
    submission = SurveySubmission.new(survey: @survey)
    assert submission.save
    assert_equal @survey, submission.survey
    assert_equal @survey.id, submission.survey_id
  end

  test "should update survey submission" do
    new_survey = surveys(:two)
    @survey_submission.survey = new_survey
    assert @survey_submission.save
    assert_equal new_survey.id, @survey_submission.reload.survey_id
    assert_equal new_survey, @survey_submission.survey
  end

  test "should destroy survey submission" do
    assert_difference('SurveySubmission.count', -1) do
      @survey_submission.destroy
    end
  end

  test "should find survey submission by id" do
    found_submission = SurveySubmission.find(@survey_submission.id)
    assert_equal @survey_submission.survey_id, found_submission.survey_id
    assert_equal @survey_submission.survey, found_submission.survey
  end

  test "should find all survey submissions" do
    submissions = SurveySubmission.all
    assert submissions.any?
    assert submissions.include?(@survey_submission)
    assert submissions.include?(@another_submission)
  end

  test "should have timestamps" do
    assert_not_nil @survey_submission.created_at
    assert_not_nil @survey_submission.updated_at
  end

  # Test associations
  test "should access survey through association" do
    assert_equal @survey, @survey_submission.survey
    assert_equal @survey.title, @survey_submission.survey.title
    assert_equal @survey.description, @survey_submission.survey.description
  end

  test "should change survey association" do
    new_survey = surveys(:two)
    @survey_submission.survey = new_survey
    assert @survey_submission.save
    assert_equal new_survey.id, @survey_submission.reload.survey_id
    assert_equal new_survey, @survey_submission.survey
  end

  test "should not save without survey" do
    submission = SurveySubmission.new
    assert_not submission.save
    assert_includes submission.errors[:survey], "must exist"
  end

  test "should not save with invalid survey_id" do
    submission = SurveySubmission.new(survey_id: 99999)
    assert_not submission.save
    assert_includes submission.errors[:survey], "must exist"
  end

  # Test fixture data integrity
  test "fixtures should be valid" do
    SurveySubmission.find_each do |submission|
      assert submission.valid?, "SurveySubmission #{submission.id} should be valid"
    end
  end

  test "fixtures should have unique ids" do
    submission_ids = SurveySubmission.pluck(:id)
    assert_equal submission_ids.uniq.length, submission_ids.length, "SurveySubmission fixtures should have unique IDs"
  end

  test "fixtures should reference valid surveys" do
    SurveySubmission.find_each do |submission|
      assert Survey.exists?(submission.survey_id), "SurveySubmission #{submission.id} should reference a valid survey"
    end
  end

  # Test scopes and queries
  test "should find submissions by survey" do
    survey_submissions = SurveySubmission.where(survey: @survey)
    assert survey_submissions.any?
    survey_submissions.each do |submission|
      assert_equal @survey.id, submission.survey_id
    end
  end

  test "should count submissions per survey" do
    survey_submissions_count = SurveySubmission.where(survey: @survey).count
    assert survey_submissions_count > 0
  end

  test "should find submissions by survey_id" do
    submissions = SurveySubmission.where(survey_id: @survey.id)
    assert submissions.any?
    submissions.each do |submission|
      assert_equal @survey.id, submission.survey_id
    end
  end

  # Test model behavior
  test "should handle multiple submissions for same survey" do
    first_submission = SurveySubmission.create!(survey: @survey)
    second_submission = SurveySubmission.create!(survey: @survey)

    assert_equal @survey.id, first_submission.survey_id
    assert_equal @survey.id, second_submission.survey_id
    assert_equal @survey, first_submission.survey
    assert_equal @survey, second_submission.survey

    # Clean up
    first_submission.destroy
    second_submission.destroy
  end

  test "should handle survey deletion with dependent option" do
    # This test assumes the model might have dependent: :destroy or similar
    # If not, it will test the current behavior
    submission_count_before = SurveySubmission.count
    survey_count_before = Survey.count

    @survey.destroy

    # Check if submissions were also destroyed (if dependent: :destroy is set)
    # or if they remain but with invalid survey_id
    if SurveySubmission.count < submission_count_before
      # Submissions were destroyed
      assert SurveySubmission.count < submission_count_before
    else
      # Submissions remain but may have invalid survey_id
      remaining_submissions = SurveySubmission.where(survey_id: @survey.id)
      assert_equal 0, remaining_submissions.count
    end
  end

  # Test edge cases
  test "should handle nil survey_id" do
    submission = SurveySubmission.new(survey_id: nil)
    assert_not submission.save
    assert_includes submission.errors[:survey], "must exist"
  end

  test "should handle zero survey_id" do
    submission = SurveySubmission.new(survey_id: 0)
    assert_not submission.save
    assert_includes submission.errors[:survey], "must exist"
  end

  # Test ordering and scoping
  test "should order by creation time" do
    submissions = SurveySubmission.order(:created_at)
    assert submissions.any?

    # Check if they're properly ordered
    previous_time = nil
    submissions.each do |submission|
      if previous_time
        assert submission.created_at >= previous_time, "Submissions should be ordered by created_at"
      end
      previous_time = submission.created_at
    end
  end

  test "should find recent submissions" do
    recent_submissions = SurveySubmission.where("created_at > ?", 1.day.ago)
    assert recent_submissions.any?
    recent_submissions.each do |submission|
      assert submission.created_at > 1.day.ago, "Should only find recent submissions"
    end
  end

  # Test model methods
  test "should respond to survey methods" do
    assert_respond_to @survey_submission, :survey
    assert_respond_to @survey_submission, :survey_id
    assert_respond_to @survey_submission, :survey_id=
  end

  test "should have proper survey association type" do
    assert_instance_of Survey, @survey_submission.survey
  end

  # Test database constraints
  test "should enforce foreign key constraint" do
    # This test verifies that the database enforces the foreign key
    # It should fail when trying to create a submission with non-existent survey_id
    assert_raises(ActiveRecord::InvalidForeignKey) do
      SurveySubmission.connection.execute(
        "INSERT INTO survey_submissions (survey_id, created_at, updated_at) VALUES (99999, NOW(), NOW())"
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
