class Program < ActiveRecord::Base
  has_many :program_exercises
  has_many :exercises, through: :program_exercises
  has_many :workouts
  before_save :save_slug

  def to_param
    slug
  end

  private

  def save_slug
    self.slug = name.parameterize
  end
end
