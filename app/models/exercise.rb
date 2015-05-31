class Exercise < ActiveRecord::Base
  has_many :program_exercises
  has_many :workouts, through: :program_exercises
end
