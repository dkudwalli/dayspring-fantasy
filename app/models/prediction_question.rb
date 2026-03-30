class PredictionQuestion < ApplicationRecord
  belongs_to :match
  belongs_to :correct_option, class_name: "PredictionOption", optional: true

  has_many :options, class_name: "PredictionOption", dependent: :destroy, inverse_of: :prediction_question
  has_many :active_options, -> { active.ordered }, class_name: "PredictionOption", inverse_of: :prediction_question
  has_many :predictions, dependent: :destroy
  has_many :prediction_submissions, dependent: :destroy

  validates :prompt, presence: true
  validates :point_value, numericality: { greater_than: 0 }
  validate :correct_option_belongs_to_question
  validate :published_result_requires_correct_option

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :ordered, -> { order(:created_at, :id) }

  def archived?
    archived_at.present?
  end

  def result_published?
    result_published_at.present?
  end

  def open_for_predictions?
    !archived? && !match.archived? && !result_published? && !match.locked?
  end

  def archive!
    update!(archived_at: Time.current)
  end

  def restore!
    update!(archived_at: nil)
  end

  private

  def correct_option_belongs_to_question
    return if correct_option.blank? || id.blank?
    return if correct_option.prediction_question_id == id

    errors.add(:correct_option_id, "must belong to this question")
  end

  def published_result_requires_correct_option
    return if !result_published? || correct_option.present?

    errors.add(:correct_option_id, "must be selected before publishing results")
  end
end
