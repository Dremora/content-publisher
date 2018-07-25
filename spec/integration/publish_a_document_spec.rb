# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Publishing a document", type: :feature do
  scenario "User publishes a document" do
    given_there_is_a_document
    when_i_visit_the_document_page
    and_i_click_on_the_publish_button
    then_i_see_the_publish_succeeded
  end

  def given_there_is_a_document
    @document = create :document, :press_release
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_click_on_the_publish_button
    @request = stub_publishing_api_publish(@document.content_id, {})
    click_on "publish"
  end

  def then_i_see_the_publish_succeeded
    expect(@request).to have_been_requested
    expect(page).to have_content "Publish successful"
  end
end