class Admin::QuestionOptionsController < Admin::BaseController
  before_action :set_match
  before_action :set_question
  before_action :set_option

  def destroy
    deleted_option_attributes = option_audit_metadata(@option)

    ActiveRecord::Base.transaction do
      @option.destroy!
      audit_admin_action!(
        action: "option_deleted",
        auditable: @option,
        match: @match,
        metadata: deleted_option_attributes.merge("question_id" => @question.id)
      )
    end

    redirect_to edit_admin_match_question_path(@match, @question), notice: "Option deleted."
  rescue ActiveRecord::RecordNotDestroyed
    redirect_to edit_admin_match_question_path(@match, @question), alert: @option.errors.full_messages.to_sentence.presence || "Option could not be deleted."
  end

  private

  def option_audit_metadata(option)
    option.attributes.slice("id", "label", "position", "archived_at")
  end

  def set_match
    @match = Match.find(params[:match_id])
  end

  def set_question
    @question = @match.prediction_questions.find(params[:question_id])
  end

  def set_option
    @option = @question.options.find(params[:id])
  end
end
