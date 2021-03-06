# frozen_string_literal: true

RSpec.feature "Download a image" do
  scenario do
    given_there_is_a_document_with_images
    when_i_visit_the_documents_image_index_page
    and_i_click_the_link_to_download_the_image
    then_the_image_should_have_been_downloaded
  end

  def given_there_is_a_document_with_images
    document_type = build(:document_type, lead_image: true)
    @document = create(:document, document_type_id: document_type.id)
    @image = create(:image, :in_preview, document: @document)
  end

  def when_i_visit_the_documents_image_index_page
    visit document_images_path(@document)
  end

  def and_i_click_the_link_to_download_the_image
    within("#image-#{@image.id}") do
      click_on("Download 960x640 image")
    end
  end

  def then_the_image_should_have_been_downloaded
    expect(page.response_headers["Content-Disposition"]).to eq("attachment; filename=\"#{@image.filename}\"")
  end
end
