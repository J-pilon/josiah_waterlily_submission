require "test_helper"

class QuestionTest < ActiveSupport::TestCase
  def setup
    @question = questions(:one)
    @another_question = questions(:two)
    @survey = surveys(:one)
  end

  test "should be valid" do
    assert @question.valid?
  end

  test "should have required attributes" do
    assert_respond_to @question, :title
    assert_respond_to @question, :description
    assert_respond_to @question, :survey_id
    assert_respond_to @question, :created_at
    assert_respond_to @question, :updated_at
  end

  test "should have title" do
    assert_equal "MyString", @question.title
  end

  test "should have description" do
    assert_equal "MyString", @question.description
  end

  test "should belong to survey" do
    assert_respond_to @question, :survey
    assert_equal @survey, @question.survey
  end

  test "should have survey_id" do
    assert_equal @survey.id, @question.survey_id
  end

  test "should create a new question" do
    question = Question.new(title: "Test Question", description: "Test Description", survey: @survey)
    assert question.save
    assert_equal "Test Question", question.title
    assert_equal "Test Description", question.description
    assert_equal @survey, question.survey
  end

  test "should update question attributes" do
    @question.title = "Updated Title"
    @question.description = "Updated Description"
    assert @question.save
    assert_equal "Updated Title", @question.reload.title
    assert_equal "Updated Description", @question.reload.description
  end

  test "should destroy question" do
    assert_difference('Question.count', -1) do
      @question.destroy
    end
  end

  test "should find question by id" do
    found_question = Question.find(@question.id)
    assert_equal @question.title, found_question.title
    assert_equal @question.description, found_question.description
    assert_equal @question.survey_id, found_question.survey_id
  end

  test "should find all questions" do
    questions = Question.all
    assert questions.any?
    assert questions.include?(@question)
    assert questions.include?(@another_question)
  end

  test "should have timestamps" do
    assert_not_nil @question.created_at
    assert_not_nil @question.updated_at
  end

  test "should update timestamps on save" do
    original_updated_at = @question.updated_at
    sleep(1) # Ensure time difference
    @question.title = "New Title"
    @question.save!
    assert @question.updated_at > original_updated_at
  end

  # Test associations
  test "should access survey through association" do
    assert_equal @survey, @question.survey
    assert_equal @survey.title, @question.survey.title
    assert_equal @survey.description, @question.survey.description
  end

  test "should change survey association" do
    new_survey = surveys(:two)
    @question.survey = new_survey
    assert @question.save
    assert_equal new_survey.id, @question.reload.survey_id
    assert_equal new_survey, @question.survey
  end

  test "should not save without survey" do
    question = Question.new(title: "Test Question", description: "Test Description")
    assert_not question.save
    assert_includes question.errors[:survey], "must exist"
  end

  test "should not save with invalid survey_id" do
    question = Question.new(title: "Test Question", description: "Test Description", survey_id: 99999)
    assert_not question.save
    assert_includes question.errors[:survey], "must exist"
  end

  # Test fixture data integrity
  test "fixtures should be valid" do
    Question.find_each do |question|
      assert question.valid?, "Question #{question.id} should be valid"
    end
  end

  test "fixtures should have unique ids" do
    question_ids = Question.pluck(:id)
    assert_equal question_ids.uniq.length, question_ids.length, "Question fixtures should have unique IDs"
  end

  test "fixtures should reference valid surveys" do
    Question.find_each do |question|
      assert Survey.exists?(question.survey_id), "Question #{question.id} should reference a valid survey"
    end
  end

  # Test model behavior with different data types
  test "should handle long titles" do
    long_title = "A" * 255
    question = Question.new(title: long_title, description: "Test Description", survey: @survey)
    assert question.save
    assert_equal long_title, question.title
  end

  test "should handle long descriptions" do
    long_description = "A" * 1000
    question = Question.new(title: "Test Title", description: long_description, survey: @survey)
    assert question.save
    assert_equal long_description, question.description
  end

  test "should handle special characters in title and description" do
    special_title = "Question with special chars: !@#$%^&*()"
    special_description = "Description with symbols: <>&\"'"
    question = Question.new(title: special_title, description: special_description, survey: @survey)
    assert question.save
    assert_equal special_title, question.title
    assert_equal special_description, question.description
  end

  # Test scopes and queries
  test "should find questions by survey" do
    survey_questions = Question.where(survey: @survey)
    assert survey_questions.any?
    survey_questions.each do |question|
      assert_equal @survey.id, question.survey_id
    end
  end

  test "should count questions per survey" do
    survey_questions_count = Question.where(survey: @survey).count
    assert survey_questions_count > 0
  end

  # Test edge cases
  test "should handle empty string title" do
    question = Question.new(title: "", description: "Test Description", survey: @survey)
    assert_not question.save
    assert_includes question.errors[:title], "can't be blank"
  end

  test "should handle empty string description" do
    question = Question.new(title: "Test Title", description: "", survey: @survey)
    assert_not question.save
    assert_includes question.errors[:description], "can't be blank"
  end

  test "should handle nil title" do
    question = Question.new(title: nil, description: "Test Description", survey: @survey)
    assert_not question.save
    assert_includes question.errors[:title], "can't be blank"
  end

  test "should handle nil description" do
    question = Question.new(title: "Test Title", description: nil, survey: @survey)
    assert_not question.save
    assert_includes question.errors[:description], "can't be blank"
  end
end
