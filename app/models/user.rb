class User < ApplicationRecord
  ALLOWED_EMAIL_DOMAINS = %w[dayspringlabs.com dayspring.tech].freeze
  POINTS_CASE_SQL = <<~SQL.squish.freeze
    CASE
      WHEN prediction_questions.result_published_at IS NOT NULL
       AND predictions.prediction_option_id = prediction_questions.correct_option_id
      THEN prediction_questions.point_value
      ELSE 0
    END
  SQL
  LEADERBOARD_SCORE_SQL = <<~SQL.squish.freeze
    COALESCE(SUM(#{POINTS_CASE_SQL}), 0)
  SQL

  has_secure_password
  generates_token_for :password_reset, expires_in: 15.minutes do
    password_digest&.last(10)
  end

  has_many :predictions, dependent: :destroy
  has_many :prediction_submissions, dependent: :destroy

  before_validation :normalize_email

  validates :email, presence: true, uniqueness: true
  validate :email_domain_must_be_allowed

  scope :non_admin, -> { where(admin: false) }
  scope :with_leaderboard_score, lambda {
    left_joins(predictions: :prediction_question)
      .select("users.*, #{LEADERBOARD_SCORE_SQL} AS leaderboard_score")
      .group("users.id")
  }
  scope :leaderboard, -> { non_admin.with_leaderboard_score.order(Arel.sql("leaderboard_score DESC, users.email ASC")) }

  def score
    return self[:leaderboard_score].to_i if has_attribute?(:leaderboard_score)

    predictions.joins(:prediction_question).sum(Arel.sql(POINTS_CASE_SQL))
  end

  def self.top_ranked(limit)
    leaderboard.limit(limit)
  end

  def self.rank_for(user)
    ranked_leaderboard.where("ranked_users.id = ?", user.id).first&.leaderboard_rank
  end

  def self.ranked_leaderboard
    base_sql = leaderboard.unscope(:order).to_sql

    from("(#{base_sql}) ranked_users")
      .select("ranked_users.*, ROW_NUMBER() OVER (ORDER BY ranked_users.leaderboard_score DESC, ranked_users.email ASC) AS leaderboard_rank")
      .order(Arel.sql("leaderboard_rank ASC"))
  end

  def daily_points_for(date)
    predictions.joins(prediction_question: :match)
      .where(matches: { starts_at: date.beginning_of_day..date.end_of_day })
      .sum(Arel.sql(self.class::POINTS_CASE_SQL))
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def email_domain_must_be_allowed
    domain = email.to_s.split("@").last
    return if ALLOWED_EMAIL_DOMAINS.include?(domain)

    errors.add(:email, "must use @dayspringlabs.com or @dayspring.tech")
  end
end
