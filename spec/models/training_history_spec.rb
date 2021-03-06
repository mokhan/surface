require "rails_helper"

describe TrainingHistory do
  include_context "stronglifts_program"
  subject { TrainingHistory.new(user, squat) }
  let(:user) { create(:user) }

  describe "#to_line_chart" do
    let(:date) { DateTime.now.utc }
    let(:target_weight) { rand(300) }
    let(:body_weight) { 210 }

    before :each do
      session = user.begin_workout(routine_a, date, body_weight)
      5.times do
        session.train(squat, target_weight, repetitions: 5)
        session.train(bench_press, target_weight + 10, repetitions: 5)
      end
    end

    it "returns the history in the format required for the chart" do
      result = subject.to_line_chart
      expect(result).to_not be_nil
      expect(result.keys.first.to_i).to eql(date.to_i)
      expect(result.keys.count).to eql(1)
      expect(result.values.first).to eql(target_weight.to_f)
    end
  end

  describe "#completed_any" do
    describe "when this exercise has never been performed" do
      it "returns false" do
        expect(subject.completed_any?).to be_falsey
      end
    end

    describe "when the exercise has been performed at least once" do
      it "returns true" do
        session = user.begin_workout(routine_a, DateTime.now, 225)
        3.times do
          session.train(squat, 310, repetitions: 5)
        end
        expect(subject.completed_any?).to be_truthy
      end
    end
  end
end
