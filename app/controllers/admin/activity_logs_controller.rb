class Admin::ActivityLogsController < Admin::BaseController
  PER_PAGE = 50

  def index
    @page = [params[:page].to_i, 1].max

    scoped_logs = AdminAuditLog.includes(:admin_user, :match).order(created_at: :desc)

    if params[:admin].present?
      scoped_logs = scoped_logs.joins(:admin_user).where("users.email ILIKE ?", "%#{params[:admin].strip}%")
    end

    if params[:log_action].present?
      scoped_logs = scoped_logs.where(action: params[:log_action])
    end

    if params[:entity_type].present?
      scoped_logs = scoped_logs.where(auditable_type: params[:entity_type])
    end

    if (date_from = parse_date(params[:date_from]))
      scoped_logs = scoped_logs.where(created_at: date_from.beginning_of_day..)
    end

    if (date_to = parse_date(params[:date_to]))
      scoped_logs = scoped_logs.where(created_at: ..date_to.end_of_day)
    end

    @total_pages = [(scoped_logs.count.to_f / PER_PAGE).ceil, 1].max
    @page = [@page, @total_pages].min
    @activity_logs = scoped_logs.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)
  end

  private

  def parse_date(value)
    Date.parse(value) if value.present?
  rescue ArgumentError
    nil
  end
end
