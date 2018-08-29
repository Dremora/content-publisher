# frozen_string_literal: true

class GovspeakController < ApplicationController
  def to_html
    render plain: Govspeak::Document.new(params[:govspeak]).to_html
  end
end
