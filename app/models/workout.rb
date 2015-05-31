class Workout < ActiveRecord::Base
  belongs_to :program
  has_many :program_exercises
  has_many :exercises, through: :program_exercises

  def slug
    name.parameterize
  end

  def to_param
    slug
  end

  def add_exercise(exercise, sets: 5, repetitions: 5)
    program_exercises.create!(
      exercise: exercise,
      sets: sets,
      repetitions: repetitions,
      program: program
    )
  end
end
