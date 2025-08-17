class Question < ApplicationRecord
  belongs_to :survey

  validates :title, :description, presence: true
end
