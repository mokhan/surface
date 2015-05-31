class ProgramExercise < ActiveRecord::Base
  belongs_to :exercise
  belongs_to :workout
  belongs_to :program
end
