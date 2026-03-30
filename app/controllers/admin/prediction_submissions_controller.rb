class Admin::PredictionSubmissionsController < Admin::BaseController
  PER_PAGE = 50

  def index
    @matches = Match.ordered
    @page = [params[:page].to_i, 1].max

    scoped_submissions = PredictionSubmission.includes(
      :user,
      :match,
      :prediction_question,
      :prediction_option
    ).order(submitted_at: :desc)

    if params[:user].present?
      scoped_submissions = scoped_submissions.joins(:user).where("users.email ILIKE ?", "%#{params[:user].strip}%")
    end

    if params[:match_id].present?
      scoped_submissions = scoped_submissions.where(match_id: params[:match_id])
    end

    if params[:action_type].present?
      scoped_submissions = scoped_submissions.where(action_type: params[:action_type])
    end

    if (date_from = parse_date(params[:date_from]))
      scoped_submissions = scoped_submissions.where(submitted_at: date_from.beginning_of_day..)
    end

    if (date_to = parse_date(params[:date_to]))
      scoped_submissions = scoped_submissions.where(submitted_at: ..date_to.end_of_day)
    end

    @total_pages = [(scoped_submissions.count.to_f / PER_PAGE).ceil, 1].max
    @page = [@page, @total_pages].min
    @prediction_submissions = scoped_submissions.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
  end

  private

  def parse_date(value)
    Date.parse(value) if value.present?
  rescue ArgumentError
    nil
  end
end
