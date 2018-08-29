# frozen_string_literal: true

RSpec.feature "Create a statistical data set", format: true do
  scenario "User creates statistical data set" do
    when_i_choose_this_document_type
    and_i_fill_in_the_form_fields
    and_i_add_some_associations
    then_i_can_publish_the_document
  end

  def when_i_choose_this_document_type
    visit "/"
    click_on "New document"
    choose SupertypeSchema.find("transparency").label
    click_on "Continue"
    choose DocumentTypeSchema.find("statistical_data_set").label
    click_on "Continue"
  end

  def and_i_fill_in_the_form_fields
    stub_any_publishing_api_put_content
    fill_in "document[title]", with: "A great title"
    fill_in "document[summary]", with: "A great summary"
    click_on "Save"
    WebMock.reset!
  end

  def and_i_add_some_associations
    stub_any_publishing_api_put_content
    expect(Document.last.document_type_schema.associations.count).to eq(2)
    publishing_api_has_linkables([linkable], document_type: "organisation")

    click_on "Change Tags"

    select linkable["internal_name"], from: "associations[organisations][]"

    click_on "Save"
  end

  def then_i_can_publish_the_document
    expect(a_request(:put, /content/).with { |req|
             expect(req.body).to be_valid_against_schema("statistical_data_set")
             expect(JSON.parse(req.body)).to match a_hash_including(content_body)
           }).to have_been_requested
  end

  def content_body
    {
      "links" => {
        "organisations" => [linkable["content_id"]],
        "primary_publishing_organisation" => [linkable["content_id"]],
      },
      "title" => "A great title",
      "document_type" => "statistical_data_set",
      "description" => "A great summary",
    }
  end

  def linkable
    @linkable ||= { "content_id" => SecureRandom.uuid, "internal_name" => "Linkable" }
  end
end