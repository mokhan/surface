require "rails_helper"

describe TrainingSession, type: :model do
  describe ".create_workout_from" do
    include_context "stronglifts_program"
    let(:user) { create(:user) }

    let(:row) do
      [
        31,
        "2015-05-13 06:10:21",
        "A",
        "{\"weight\":{\"lastWeightKg\":90,\"lastWeightLb\":200},\"success\":false,\"set1\":-1,\"set2\":-1,\"set3\":-1,\"set4\":-1,\"set5\":-1,\"messageDismissed\":false,\"workoutType\":0,\"warmup\":{\"exerciseType\":1,\"targetWeight\":200,\"warmupSets\":[{\"completed\":false},{\"completed\":false},{\"completed\":false},{\"completed\":false},{\"completed\":false}]}}", 
        "{\"weight\":{\"lastWeightKg\":65,\"lastWeightLb\":145},\"success\":true,\"set1\":5,\"set2\":5,\"set3\":5,\"set4\":5,\"set5\":5,\"messageDismissed\":false,\"workoutType\":0,\"warmup\":{\"exerciseType\":2,\"targetWeight\":145,\"warmupSets\":[{\"completed\":true},{\"completed\":true},{\"completed\":true},{\"completed\":true}]}}", 
        "{\"weight\":{\"lastWeightKg\":60,\"lastWeightLb\":130},\"success\":false,\"set1\":5,\"set2\":4,\"set3\":4,\"set4\":4,\"set5\":4,\"messageDismissed\":false,\"workoutType\":0,\"warmup\":{\"exerciseType\":3,\"targetWeight\":130,\"warmupSets\":[{\"completed\":true}]}}", 
        "",
        "209LB",
        "{\"set1\":8,\"set2\":4,\"set3\":4,\"messageDismissed\":false,\"exercise\":0,\"weight\":{\"lastWeightKg\":0,\"lastWeightLb\":0}}",
        0
      ]
    end

    let(:workout_row) do
      WorkoutRow.new(
        id: row[0],
        date: DateTime.parse(row[1]),
        workout: row[2],
        exercise_1: JSON.parse(row[3]),
        exercise_2: JSON.parse(row[4]),
        exercise_3: JSON.parse(row[5]),
        note: row[6],
        body_weight: row[7],
        arm_work: JSON.parse(row[8])
      )
    end

    it 'creates a new workout' do
      training_session = user.training_sessions.create_workout_from(workout_row)

      expect(training_session).to be_persisted
      expect(training_session.occurred_at).to eql(workout_row.date)
      #expect(training_session.workout).to eql(workout_a)
      expect(training_session.body_weight).to eql(209.0)
      expect(training_session.exercise_sessions.count).to eql(3)
      expect(training_session.exercise_sessions.map { |x| x.exercise.name }).to match_array(["Squat", "Bench Press", "Barbell Row"])

      squat_session = training_session.exercise_sessions.find_by(program_exercise: squat_workout)
      expect(squat_session.target_weight).to eql(200.0)
      expect(squat_session.sets[0]).to eql('0')
      expect(squat_session.sets[1]).to eql('0')
      expect(squat_session.sets[2]).to eql('0')
      expect(squat_session.sets[3]).to eql('0')
      expect(squat_session.sets[4]).to eql('0')

      bench_session = training_session.exercise_sessions.find_by(program_exercise: bench_workout)
      expect(bench_session.target_weight).to eql(145.0)
      expect(bench_session.sets[0]).to eql("5")
      expect(bench_session.sets[1]).to eql("5")
      expect(bench_session.sets[2]).to eql("5")
      expect(bench_session.sets[3]).to eql("5")
      expect(bench_session.sets[4]).to eql("5")

      row_session = training_session.exercise_sessions.find_by(program_exercise: row_workout)
      expect(row_session.target_weight).to eql(130.0)
      expect(row_session.sets[0]).to eql("5")
      expect(row_session.sets[1]).to eql("4")
      expect(row_session.sets[2]).to eql("4")
      expect(row_session.sets[3]).to eql("4")
      expect(row_session.sets[4]).to eql("4")
    end

    it 'excludes items that have already been imported' do
      training_session = user.training_sessions.create_workout_from(workout_row)
      expect(user.training_sessions.create_workout_from(workout_row)).to eql(training_session)
    end
  end
end
