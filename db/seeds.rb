# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Seeding database..."

# Clear existing data (optional - comment out if you want to preserve existing data)
# SurveySubmission.destroy_all
# Answer.destroy_all
# Question.destroy_all
# Survey.destroy_all

# Create Customer Satisfaction Survey
customer_survey = Survey.find_or_create_by!(title: "Customer Satisfaction Survey") do |survey|
  survey.description = "Help us improve our services by providing feedback on your recent experience"
end

puts "Created survey: #{customer_survey.title}"

# Questions for Customer Satisfaction Survey
customer_questions = [
  {
    title: "Overall Satisfaction",
    description: "How satisfied are you with our service overall?"
  },
  {
    title: "Service Quality",
    description: "How would you rate the quality of our service?"
  },
  {
    title: "Staff Friendliness",
    description: "How friendly and helpful was our staff?"
  },
  {
    title: "Value for Money",
    description: "Do you feel you received good value for your money?"
  },
  {
    title: "Recommendation",
    description: "How likely are you to recommend our service to others?"
  }
]

customer_questions.each do |question_data|
  question = customer_survey.questions.find_or_create_by!(title: question_data[:title]) do |q|
    q.description = question_data[:description]
  end
  puts "  - Created question: #{question.title}"
end

# Create Employee Engagement Survey
employee_survey = Survey.find_or_create_by!(title: "Employee Engagement Survey") do |survey|
  survey.description = "Annual survey to measure employee satisfaction and engagement levels"
end

puts "Created survey: #{employee_survey.title}"

# Questions for Employee Engagement Survey
employee_questions = [
  {
    title: "Job Satisfaction",
    description: "How satisfied are you with your current role?"
  },
  {
    title: "Work Environment",
    description: "How would you rate your work environment and culture?"
  },
  {
    title: "Management Support",
    description: "How supported do you feel by your immediate supervisor?"
  },
  {
    title: "Career Growth",
    description: "Do you see opportunities for career growth in this organization?"
  },
  {
    title: "Work-Life Balance",
    description: "How would you rate your work-life balance?"
  },
  {
    title: "Compensation",
    description: "How satisfied are you with your compensation and benefits?"
  }
]

employee_questions.each do |question_data|
  question = employee_survey.questions.find_or_create_by!(title: question_data[:title]) do |q|
    q.description = question_data[:description]
  end
  puts "  - Created question: #{question.title}"
end

# Create Product Feedback Survey
product_survey = Survey.find_or_create_by!(title: "Product Feedback Survey") do |survey|
  survey.description = "Share your thoughts on our latest product features and improvements"
end

puts "Created survey: #{product_survey.title}"

# Questions for Product Feedback Survey
product_questions = [
  {
    title: "Product Usability",
    description: "How easy is it to use our product?"
  },
  {
    title: "Feature Completeness",
    description: "Do our current features meet your needs?"
  },
  {
    title: "Performance",
    description: "How would you rate the performance of our product?"
  },
  {
    title: "Design",
    description: "How would you rate the visual design and user interface?"
  },
  {
    title: "Support Quality",
    description: "How satisfied are you with our customer support?"
  }
]

product_questions.each do |question_data|
  question = product_survey.questions.find_or_create_by!(title: question_data[:title]) do |q|
    q.description = question_data[:description]
  end
  puts "  - Created question: #{question.title}"
end

# Create Event Feedback Survey
event_survey = Survey.find_or_create_by!(title: "Event Feedback Survey") do |survey|
  survey.description = "Help us improve future events by providing feedback on this one"
end

puts "Created survey: #{event_survey.title}"

# Questions for Event Feedback Survey
event_questions = [
  {
    title: "Event Organization",
    description: "How well was the event organized and managed?"
  },
  {
    title: "Content Quality",
    description: "How would you rate the quality of the event content and presentations?"
  },
  {
    title: "Venue",
    description: "How would you rate the venue and facilities?"
  },
  {
    title: "Networking Opportunities",
    description: "How valuable were the networking opportunities?"
  },
  {
    title: "Future Attendance",
    description: "How likely are you to attend future events?"
  }
]

event_questions.each do |question_data|
  question = event_survey.questions.find_or_create_by!(title: question_data[:title]) do |q|
    q.description = question_data[:description]
  end
  puts "  - Created question: #{question.title}"
end

puts "\nSeeding completed!"
puts "Total surveys created: #{Survey.count}"
puts "Total questions created: #{Question.count}"
