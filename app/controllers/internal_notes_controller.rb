# frozen_string_literal: true

class InternalNotesController < ApplicationController
  def create
    if permitted_params.fetch(:body).blank?
      return redirect_to :back
    end

    document = Document.find_by_param(params[:id])

    ActiveRecord::Base.transaction do
      timeline_entry = TimelineEntry.create!(document: document, user: current_user, entry_type: "internal_note")

      InternalNote.create!(
        body: permitted_params[:body],
        timeline_entry: timeline_entry,
        user: current_user,
        document: document
      )
    end

    redirect_to document_path(document)
  end

  private

  def permitted_params
    params.permit(:body)
  end
end
