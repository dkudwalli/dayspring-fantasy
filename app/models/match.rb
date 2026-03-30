class Match < ApplicationRecord
  has_many :prediction_questions, dependent: :destroy
  has_many :prediction_submissions, dependent: :destroy
  has_many :active_prediction_questions, -> { active.ordered }, class_name: "PredictionQuestion"

  validates :team_one, :team_two, :starts_at, presence: true
  validates :team_one, uniqueness: { scope: %i[team_two starts_at], message: "match already exists at that time" }

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :ordered, -> { order(:starts_at) }
  scope :visible_to_users, -> { active.ordered }
  scope :on_date, ->(date) { where(starts_at: date.beginning_of_day..date.end_of_day).ordered }

  def name
    "#{team_one} vs #{team_two}"
  end

  def archived?
    archived_at.present?
  end

  def locked?
    starts_at <= Time.current
  end

  def archive!
    update!(archived_at: Time.current)
  end

  def restore!
    update!(archived_at: nil)
  end
end
