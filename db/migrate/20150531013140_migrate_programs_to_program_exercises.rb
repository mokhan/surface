class MigrateProgramsToProgramExercises < ActiveRecord::Migration
  def change
    ActiveRecord::Base.transaction do
      ProgramExercise.find_each do |program_exercise|
        program_exercise.program = program_exercise.workout.program
        program_exercise.save!
      end
    end
    change_column :program_exercises, :program_id, :uuid, null: false
  end
end
