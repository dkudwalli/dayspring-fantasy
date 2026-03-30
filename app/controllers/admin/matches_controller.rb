class Admin::MatchesController < Admin::BaseController
  require "csv"

  def index
    @matches = Match.ordered.includes(:prediction_questions)
  end

  def new
    @match = Match.new
  end

  def edit
    @match = Match.includes(prediction_questions: :options).find(params[:id])
  end

  def create
    @match = Match.new(match_params)

    ActiveRecord::Base.transaction do
      @match.save!
      audit_admin_action!(action: "match_created", auditable: @match, metadata: match_audit_metadata(@match))
    end

    redirect_to edit_admin_match_path(@match), notice: "Match created."
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_content
  end

  def update
    @match = Match.find(params[:id])

    ActiveRecord::Base.transaction do
      @match.update!(match_params)
      audit_admin_action!(action: "match_updated", auditable: @match, metadata: match_audit_metadata(@match))
    end

    redirect_to edit_admin_match_path(@match), notice: "Match updated."
  rescue ActiveRecord::RecordInvalid
    render :edit, status: :unprocessable_content
  end

  def archive
    @match = Match.find(params[:id])
    ActiveRecord::Base.transaction do
      @match.archive!
      audit_admin_action!(action: "match_archived", auditable: @match, metadata: match_audit_metadata(@match))
    end

    redirect_to admin_root_path, notice: "Match archived."
  end

  def restore
    @match = Match.find(params[:id])
    ActiveRecord::Base.transaction do
      @match.restore!
      audit_admin_action!(action: "match_restored", auditable: @match, metadata: match_audit_metadata(@match))
    end

    redirect_to admin_root_path, notice: "Match restored."
  end

  def import
    file = params[:schedule_csv]

    if file.blank?
      redirect_to admin_root_path, alert: "Choose a CSV file to import."
      return
    end

    imported = 0
    updated = 0

    ActiveRecord::Base.transaction do
      CSV.foreach(file.path, headers: true) do |row|
        starts_at = Time.zone.parse(row.fetch("starts_at").to_s)

        if row["team_one"].blank? || row["team_two"].blank? || starts_at.blank?
          raise ArgumentError, "Each row must include team_one, team_two, and starts_at."
        end

        match = Match.find_or_initialize_by(
          team_one: row["team_one"].to_s.strip,
          team_two: row["team_two"].to_s.strip,
          starts_at: starts_at
        )
        was_new_record = match.new_record?
        match.assign_attributes(
          venue: row["venue"].to_s.strip.presence,
          archived_at: nil
        )
        match.save!

        was_new_record ? imported += 1 : updated += 1
      end

      audit_admin_action!(
        action: "matches_imported",
        auditable_type: "Match",
        metadata: {
          imported: imported,
          updated: updated,
          filename: file.original_filename.presence || File.basename(file.path)
        }
      )
    end

    redirect_to admin_root_path, notice: "Schedule import complete: #{imported} created, #{updated} updated."
  rescue ArgumentError, KeyError, CSV::MalformedCSVError, ActiveRecord::RecordInvalid => error
    redirect_to admin_root_path, alert: "Import failed: #{error.message}"
  end

  private

  def match_params
    params.require(:match).permit(:team_one, :team_two, :venue, :starts_at)
  end

  def match_audit_metadata(match)
    match.attributes.slice("team_one", "team_two", "venue", "starts_at", "archived_at")
  end
end
