# frozen_string_literal: true

class RetireDocumentController < ApplicationController
  def create
    @document = Document.find_by_param(params[:id])
  end

  def new
    document = Document.find_by_param(params[:id])
    explanatory_note = params[:explanatory_note]
    DocumentUnpublishingService.new.retire(document, explanatory_note)
    redirect_to document
  end
end
