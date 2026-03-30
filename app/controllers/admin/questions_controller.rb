class Admin::QuestionsController < Admin::BaseController
  before_action :set_match
  before_action :set_question, only: %i[edit update archive restore]

  def new
    @question = @match.prediction_questions.new(point_value: 1)
  end

  def edit
  end

  def create
    @question = @match.prediction_questions.new(question_params)
    build_options(@question, params[:prediction_question][:option_labels])

    if @question.errors.empty?
      ActiveRecord::Base.transaction do
        @question.save!
        audit_admin_action!(action: "question_created", auditable: @question, match: @match, metadata: question_audit_metadata(@question))
      end

      redirect_to edit_admin_match_path(@match), notice: "Question created."
    else
      render :new, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_content
  end

  def update
    published_before = @question.result_published?

    ActiveRecord::Base.transaction do
      @question.assign_attributes(question_params.except(:correct_option_id, :publish_result, :new_option_labels, :option_updates))
      @question.correct_option_id = question_params[:correct_option_id].presence
      option_events = apply_option_updates(@question, question_params[:option_updates])
      new_options = build_new_options(@question, question_params[:new_option_labels])
      apply_result_publication(@question, question_params[:publish_result])
      @question.save!
      audit_admin_action!(
        action: audit_action_for(@question, published_before: published_before),
        auditable: @question,
        match: @match,
        metadata: question_audit_metadata(@question)
      )
      audit_option_events!(option_events)
      audit_new_options!(new_options)
    end

    redirect_to edit_admin_match_path(@match), notice: "Question updated."
  rescue ActiveRecord::RecordInvalid => error
    @question.errors.add(:base, error.record.errors.full_messages.to_sentence) unless error.record == @question
    render :edit, status: :unprocessable_content
  end

  def archive
    ActiveRecord::Base.transaction do
      @question.archive!
      audit_admin_action!(action: "question_archived", auditable: @question, match: @match, metadata: question_audit_metadata(@question))
    end

    redirect_to edit_admin_match_path(@match), notice: "Question archived."
  end

  def restore
    ActiveRecord::Base.transaction do
      @question.restore!
      audit_admin_action!(action: "question_restored", auditable: @question, match: @match, metadata: question_audit_metadata(@question))
    end

    redirect_to edit_admin_match_path(@match), notice: "Question restored."
  end

  private

  def set_match
    @match = Match.find(params[:match_id])
  end

  def set_question
    @question = @match.prediction_questions.find(params[:id])
  end

  def question_params
    params.require(:prediction_question).permit(
      :prompt,
      :point_value,
      :correct_option_id,
      :publish_result,
      :new_option_labels,
      option_updates: %i[id label position archived]
    )
  end

  def build_options(question, labels_text)
    labels = labels_text.to_s.lines.map(&:strip).reject(&:blank?).uniq

    if labels.empty?
      question.errors.add(:base, "Add at least one option.")
      return
    end

    labels.each_with_index do |label, index|
      question.options.build(label: label, position: index)
    end
  end

  def build_new_options(question, labels_text)
    labels = labels_text.to_s.lines.map(&:strip).reject(&:blank?).uniq
    return [] if labels.empty?

    starting_position = question.options.maximum(:position).to_i + 1
    new_options = []

    labels.each_with_index do |label, index|
      new_options << question.options.build(label: label, position: starting_position + index)
    end

    new_options
  end

  def apply_option_updates(question, option_updates)
    option_events = []

    option_updates.to_h.each_value do |option_params|
      option = question.options.find(option_params[:id])
      archived_before = option.archived?
      option.assign_attributes(
        label: option_params[:label],
        position: option_params[:position].to_i
      )

      if ActiveModel::Type::Boolean.new.cast(option_params[:archived])
        option.archived_at ||= Time.current
      else
        option.archived_at = nil
      end

      action = option_action_for(option, archived_before: archived_before)
      option.save!
      option_events << { action: action, option: option } if action.present?
    end

    option_events
  end

  def apply_result_publication(question, publish_result)
    return question.result_published_at = nil unless ActiveModel::Type::Boolean.new.cast(publish_result)

    if question.correct_option.blank?
      question.errors.add(:correct_option_id, "must be selected before publishing results")
      raise ActiveRecord::RecordInvalid.new(question)
    end

    question.result_published_at ||= Time.current
  end

  def audit_action_for(question, published_before:)
    return "question_published" if question.result_published? && !published_before
    return "question_unpublished" if !question.result_published? && published_before

    "question_updated"
  end

  def option_action_for(option, archived_before:)
    return "option_archived" if option.archived? && !archived_before
    return "option_restored" if !option.archived? && archived_before
    return "option_updated" if option.saved_changes.except("updated_at").present?

    nil
  end

  def audit_option_events!(option_events)
    option_events.each do |event|
      audit_admin_action!(
        action: event.fetch(:action),
        auditable: event.fetch(:option),
        match: @match,
        metadata: option_audit_metadata(event.fetch(:option))
      )
    end
  end

  def audit_new_options!(new_options)
    new_options.each do |option|
      audit_admin_action!(
        action: "option_created",
        auditable: option,
        match: @match,
        metadata: option_audit_metadata(option)
      )
    end
  end

  def question_audit_metadata(question)
    question.attributes.slice("prompt", "point_value", "correct_option_id", "result_published_at", "archived_at").merge(
      "option_count" => question.options.count,
      "active_option_count" => question.options.active.count
    )
  end

  def option_audit_metadata(option)
    option.attributes.slice("label", "position", "archived_at", "prediction_question_id")
  end
end
