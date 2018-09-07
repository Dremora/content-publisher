# frozen_string_literal: true

class DocumentsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    Rails.logger.error(e)
    render "show_api_down", status: :service_unavailable
  end

  def index
    filter = DocumentFilter.new(
      filters: params.permit(:title_or_url, :document_type, :state).to_hash,
      sort: params[:sort],
      page: params[:page],
      per_page: 50,
    )

    @documents = filter.documents
    @filter_params = filter.filter_params
    @sort = filter.sort
  end

  def edit
    @document = Document.find_by_param(params[:id])
  end

  def show
    @document = Document.find_by_param(params[:id])
  end

  def update
    document = Document.find_by_param(params[:id])
    document.update!(update_params(document))
    DocumentPublishingService.new.publish_draft(document)
    redirect_to document, notice: t("documents.show.flashes.draft_success")
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    document.update!(publication_state: "error_sending_to_draft")
    redirect_to document, alert: t("documents.show.flashes.draft_error")
  end

  def generate_path
    document = Document.find_by_param(params[:id])
    base_path = PathGeneratorService.new.path(document, params[:title])
    render plain: base_path
  rescue PathGeneratorService::ErrorGeneratingPath
    render status: :conflict
  end

private

  def index_params
    params.permit(:title_or_url, :document_type, :sort, :page)
  end

  def update_params(document)
    contents_params = document.document_type_schema.contents.map(&:id)
    base_path = PathGeneratorService.new.path(document, params[:document][:title])

    params.require(:document).permit(:title, :summary, contents: contents_params)
      .merge(base_path: base_path, publication_state: "changes_not_sent_to_draft", review_state: "unreviewed")
  end
end
