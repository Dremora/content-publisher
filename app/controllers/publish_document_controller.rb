# frozen_string_literal: true

class PublishDocumentController < ApplicationController
  def publish
    document = Document.find(params[:id])
    DocumentPublishingService.new.publish(document)
    redirect_to document, notice: "Publish successful"
  rescue GdsApi::HTTPErrorResponse, SocketError => e
    Rails.logger.error(e)
    redirect_to document, alert: "Error publishing"
  end
end
