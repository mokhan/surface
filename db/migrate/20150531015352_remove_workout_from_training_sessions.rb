class RemoveWorkoutFromTrainingSessions < ActiveRecord::Migration
  def change
    remove_column :training_sessions, :workout_id
  end
end
