# frozen_string_literal: true

RSpec.feature "Publishing a document" do
  scenario do
    given_there_is_a_document_in_draft
    when_i_visit_the_document_page
    and_i_publish_the_document
    then_i_see_the_publish_succeeded
    and_the_content_is_shown_as_published
    and_there_is_a_history_entry
  end

  def given_there_is_a_document_in_draft
    @document = create(:document, :publishable, base_path: "/news/banana-pricing-updates")
    @image = create(:image, :in_preview, document: @document)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_publish_the_document
    click_on "Publish"
    choose I18n.t!("publish_document.confirmation.has_been_reviewed")
    @content_request = stub_publishing_api_publish(@document.content_id, update_type: nil, locale: @document.locale)
    @asset_request = asset_manager_update_asset(@image.asset_manager_id)
    click_on "Confirm publish"
  end

  def then_i_see_the_publish_succeeded
    expect(@content_request).to have_been_requested
    expect(@asset_request).to have_been_requested
    expect(page).to have_content(I18n.t!("publish_document.published.reviewed.title"))
  end

  def and_the_content_is_shown_as_published
    visit document_path(@document)
    expect(page).to have_content(I18n.t!("user_facing_states.published.name"))
    expect(page).to have_link("View published edition on GOV.UK", href: "https://www.test.gov.uk/news/banana-pricing-updates")
  end

  def and_there_is_a_history_entry
    visit document_path(@document)
    expect(page).to have_content(I18n.t!("documents.history.entry_types.published"))
  end
end
