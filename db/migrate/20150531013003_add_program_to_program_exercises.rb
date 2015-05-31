class AddProgramToProgramExercises < ActiveRecord::Migration
  def change
    add_column :program_exercises, :program_id, :uuid
  end
end
