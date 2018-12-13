# frozen_string_literal: true

RSpec.feature "Upload a lead image" do
  scenario do
    given_there_is_a_document
    when_i_visit_the_images_page
    and_i_upload_a_new_image
    and_i_crop_the_image
    and_i_fill_in_the_metadata
    then_i_see_the_new_lead_image
    and_the_image_is_in_asset_manager
    and_the_preview_creation_succeeded
  end

  def given_there_is_a_document
    document_type = build(:document_type, lead_image: true)
    @document = create(:document, document_type_id: document_type.id)
  end

  def when_i_visit_the_images_page
    visit document_images_path(@document)
  end

  def and_i_upload_a_new_image
    @asset_id = SecureRandom.uuid
    @asset_url = "https://asset-manager.test.gov.uk/media/#{@asset_id}/1000x1000.jpg"
    @asset_create_request = asset_manager_receives_an_asset(@asset_url)

    find('form input[type="file"]').set(Rails.root.join(file_fixture("1000x1000.jpg")))
    click_on "Upload"
  end

  def and_i_crop_the_image
    asset_manager_update_asset(@asset_id, file_url: @asset_url)
    stub_publishing_api_put_content(@document.content_id, {})
    click_on "Crop image"
  end

  def and_i_fill_in_the_metadata
    fill_in "filename", with: "new-filename.jpg"
    fill_in "alt_text", with: "Some alt text"
    fill_in "caption", with: "A caption"
    fill_in "credit", with: "A credit"

    @asset_url = "https://asset-manager.test.gov.uk/media/#{@asset_id}/new-filename.jpg"
    @publishing_api_request = stub_publishing_api_put_content(Document.last.content_id, {})
    @asset_update_request = asset_manager_update_asset(@asset_id, file_url: @asset_url)
    click_on "Save and choose"
  end

  def then_i_see_the_new_lead_image
    expect(page).to have_content(I18n.t!("documents.show.flashes.lead_image.added", file: "new-filename.jpg"))
    expect(page).to have_content("A caption")
    expect(page).to have_content("A credit")
    expect(find("#lead-image img")["src"]).to include("new-filename.jpg")
    expect(find("#lead-image img")["alt"]).to eq("Some alt text")

    expect(page).to have_content(I18n.t!("documents.history.entry_types.lead_image_updated"))
    expect(page).to have_content(I18n.t!("documents.history.entry_types.image_updated"))
  end

  def and_the_image_is_in_asset_manager
    expect(@asset_create_request).to have_been_requested
    expect(@asset_update_request).to have_been_requested.twice
  end

  def and_the_preview_creation_succeeded
    expect(@publishing_api_request).to have_been_requested
    expect(page).to have_content(I18n.t!("user_facing_states.draft.name"))

    expect(a_request(:put, /content/).with { |req|
      expect(JSON.parse(req.body)["details"]["image"]["url"]).to eq @asset_url
      expect(JSON.parse(req.body)["details"]["image"]["alt_text"]).to eq "Some alt text"
      expect(JSON.parse(req.body)["details"]["image"]["caption"]).to eq "A caption"
    }).to have_been_requested
  end
end
