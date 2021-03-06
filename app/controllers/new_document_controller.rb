# frozen_string_literal: true

class NewDocumentController < ApplicationController
  def choose_supertype
    @supertypes = Supertype.all
  end

  def choose_document_type
    unless params[:supertype]
      redirect_to new_document_path,
        alert: t("new_document.choose_supertype.flashes.choose_error")

      return
    end

    @supertype = Supertype.find(params[:supertype])

    if @supertype.managed_elsewhere
      redirect_to @supertype.managed_elsewhere_url
      return
    end

    @document_types = @supertype.document_types
  end

  def create
    unless params[:document_type]
      redirect_to choose_document_type_path(supertype: params[:supertype]),
        alert: t("new_document.choose_document_type.flashes.choose_error")

      return
    end

    document_type = DocumentType.find(params[:document_type])

    if document_type.managed_elsewhere
      redirect_to document_type.managed_elsewhere_url
      return
    end

    document = Document.create!(
      content_id: SecureRandom.uuid,
      locale: "en",
      document_type_id: params[:document_type],
      publication_state: "changes_not_sent_to_draft",
      review_state: "unreviewed",
      tags: default_tags,
      creator_id: current_user.id,
      update_type: "major",
      change_note: "First published.",
      current_edition_number: 1,
      last_editor_id: current_user.id,
    )

    TimelineEntry.create!(document: document, user: current_user, entry_type: "created")

    redirect_to edit_document_path(document)
  end

private

  def default_tags
    current_user.organisation_content_id ? { primary_publishing_organisation: [current_user.organisation_content_id] } : {}
  end
end
