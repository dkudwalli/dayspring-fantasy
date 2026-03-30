class PredictionOption < ApplicationRecord
  belongs_to :prediction_question
  has_many :predictions, dependent: :restrict_with_error
  has_many :prediction_submissions, dependent: :restrict_with_error
  has_many :resolved_questions, class_name: "PredictionQuestion", foreign_key: :correct_option_id, inverse_of: :correct_option, dependent: :restrict_with_error

  validates :label, presence: true
  validates :position, numericality: { greater_than_or_equal_to: 0 }
  validate :active_label_must_be_unique_within_question

  scope :active, -> { where(archived_at: nil) }
  scope :archived, -> { where.not(archived_at: nil) }
  scope :ordered, -> { order(:position, :id) }

  def archived?
    archived_at.present?
  end

  def archive!
    update!(archived_at: Time.current)
  end

  def restore!
    update!(archived_at: nil)
  end

  private

  def active_label_must_be_unique_within_question
    return if archived?
    return if label.blank? || prediction_question_id.blank?

    duplicate_exists = self.class.active
      .where(prediction_question_id: prediction_question_id)
      .where("LOWER(label) = ?", label.downcase)
      .where.not(id: id)
      .exists?

    return unless duplicate_exists

    errors.add(:label, "must be unique within this question")
  end
end
