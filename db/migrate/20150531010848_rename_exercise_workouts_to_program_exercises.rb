class RenameExerciseWorkoutsToProgramExercises < ActiveRecord::Migration
  def change
    rename_table :exercise_workouts, :program_exercises
    rename_column :exercise_sessions, :exercise_workout_id, :program_exercise_id
  end
end
