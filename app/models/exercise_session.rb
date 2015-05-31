class ExerciseSession < ActiveRecord::Base
  belongs_to :training_session
  belongs_to :program_exercise
  has_one :exercise, through: :program_exercise
end
