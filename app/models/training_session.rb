class TrainingSession < ActiveRecord::Base
  belongs_to :user
  belongs_to :workout
  has_many :exercise_sessions

  def self.create_workout_from(workout_row, program: Program.find_by(name: "StrongLifts 5×5"))
    transaction do
      workout = program.workouts.find_by(name: workout_row.workout)
      matching_workouts = where(occurred_at: workout_row.date)
      if matching_workouts.any?
        session = matching_workouts.first
      else
        session = create!(
          workout: workout,
          occurred_at: workout_row.date,
          body_weight: workout_row.body_weight.to_f
        )
      end

      session.exercise_sessions.destroy_all
      workout.program_exercises.each_with_index do |program_exercise, index|
        exercise_row = workout_row.exercises[index]
        sets = []
        1.upto(program_exercise.sets).each do |n|
          if exercise_row["set#{n}"].to_i > 0
            sets << exercise_row["set#{n}"]
          else
            sets << 0
          end
        end

        session.exercise_sessions.create!(
          target_weight: exercise_row["warmup"]["targetWeight"],
          program_exercise: program_exercise,
          sets: sets
        )
      end
      session
    end
  end
end
