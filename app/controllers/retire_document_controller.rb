# frozen_string_literal: true

class RetireDocumentController < ApplicationController
  before_action { authorise_user!(User::MANAGING_EDITOR_PERMISSION) }

  def create
    @document = Document.find_by_param(params[:id])
    @explanatory_note = @document.retirement&.explanatory_note || params[:explanatory_note]
  end

  def new
    @document = Document.find_by_param(params[:id])
    explanatory_note = params[:explanatory_note]
    issues = Requirements::ExplanatoryNoteChecker.new(explanatory_note).pre_retirement_issues
    if issues.any?
      flash.now["alert_with_items"] = {
        "title" => I18n.t!("retire_document.retire.flashes.requirements"),
        "items" => issues.items,
      }

      render :create, explanatory_note: explanatory_note
      return
    end

    DocumentUnpublishingService.new.retire(@document, explanatory_note)
    redirect_to @document
  end
end
