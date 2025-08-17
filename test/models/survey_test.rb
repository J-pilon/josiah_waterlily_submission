require "test_helper"

class SurveyTest < ActiveSupport::TestCase
  def setup
    @survey = surveys(:one)
    @another_survey = surveys(:two)
  end

  test "should be valid" do
    assert @survey.valid?
  end

  test "should have required attributes" do
    assert_respond_to @survey, :title
    assert_respond_to @survey, :description
    assert_respond_to @survey, :created_at
    assert_respond_to @survey, :updated_at
  end

  test "should have title" do
    assert_equal "MyString", @survey.title
  end

  test "should have description" do
    assert_equal "MyString", @survey.description
  end

  test "should create a new survey" do
    survey = Survey.new(title: "Test Survey", description: "Test Description")
    assert survey.save
    assert_equal "Test Survey", survey.title
    assert_equal "Test Description", survey.description
  end

  test "should update survey attributes" do
    @survey.title = "Updated Title"
    @survey.description = "Updated Description"
    assert @survey.save
    assert_equal "Updated Title", @survey.reload.title
    assert_equal "Updated Description", @survey.reload.description
  end

  test "should destroy survey" do
    assert_difference('Survey.count', -1) do
      @survey.destroy
    end
  end

  test "should find survey by id" do
    found_survey = Survey.find(@survey.id)
    assert_equal @survey.title, found_survey.title
    assert_equal @survey.description, found_survey.description
  end

  test "should find all surveys" do
    surveys = Survey.all
    assert surveys.any?
    assert surveys.include?(@survey)
    assert surveys.include?(@another_survey)
  end

  test "should have timestamps" do
    assert_not_nil @survey.created_at
    assert_not_nil @survey.updated_at
  end

  test "should update timestamps on save" do
    original_updated_at = @survey.updated_at
    sleep(1) # Ensure time difference
    @survey.title = "New Title"
    @survey.save!
    assert @survey.updated_at > original_updated_at
  end

  # Test fixture data integrity
  test "fixtures should be valid" do
    Survey.find_each do |survey|
      assert survey.valid?, "Survey #{survey.id} should be valid"
    end
  end

  test "fixtures should have unique ids" do
    survey_ids = Survey.pluck(:id)
    assert_equal survey_ids.uniq.length, survey_ids.length, "Survey fixtures should have unique IDs"
  end

  # Test model behavior with different data types
  test "should handle long titles" do
    long_title = "A" * 255
    survey = Survey.new(title: long_title, description: "Test Description")
    assert survey.save
    assert_equal long_title, survey.title
  end

  test "should handle long descriptions" do
    long_description = "A" * 1000
    survey = Survey.new(title: "Test Title", description: long_description)
    assert survey.save
    assert_equal long_description, survey.description
  end

  test "should handle special characters in title and description" do
    special_title = "Survey with special chars: !@#$%^&*()"
    special_description = "Description with symbols: <>&\"'"
    survey = Survey.new(title: special_title, description: special_description)
    assert survey.save
    assert_equal special_title, survey.title
    assert_equal special_description, survey.description
  end
end
