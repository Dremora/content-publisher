# frozen_string_literal: true

RSpec.describe PublishingApiPayload do
  describe "#payload" do
    it "generates a payload for the publishing API" do
      document_type = build(:document_type)
      document = build(:document, document_type_id: document_type.id, title: "Some title", summary: "document summary", base_path: "/foo/bar/baz")

      payload = PublishingApiPayload.new(document).payload

      payload_hash = {
        "base_path" => "/foo/bar/baz",
        "description" => "document summary",
        "document_type" => document_type.id,
        "links" => { "organisations" => [] },
        "locale" => document.locale,
        "publishing_app" => "content-publisher",
        "rendering_app" => nil,
        "routes" => [{ "path" => "/foo/bar/baz", "type" => "exact" }],
        "schema_name" => nil,
        "title" => "Some title",
      }
      expect(payload).to match a_hash_including(payload_hash)
    end

    it "includes primary_publishing_organisation in organisations links" do
      organisation = build(:tag_field, type: "single_tag", id: "primary_publishing_organisation")
      document_type = build(:document_type, tags: [organisation])
      document = build(:document, document_type_id: document_type.id, tags: {
                         primary_publishing_organisation: ["my-org-id"],
                         organisations: ["other-org-id"],
                       })

      payload = PublishingApiPayload.new(document).payload

      payload_hash = {
        "links" => {
          "primary_publishing_organisation" => ["my-org-id"],
          "organisations" => ["my-org-id", "other-org-id"],
        },
      }
      expect(payload).to match a_hash_including(payload_hash)
    end

    it "ensures the organisation links are unique" do
      organisation = build(:tag_field, type: "single_tag", id: "primary_publishing_organisation")
      document_type = build(:document_type, tags: [organisation])
      document = build(:document, document_type_id: document_type.id, tags: {
                         primary_publishing_organisation: ["my-org-id"],
                         organisations: ["my-org-id"],
                       })

      payload = PublishingApiPayload.new(document).payload

      payload_hash = {
        "links" => {
          "primary_publishing_organisation" => ["my-org-id"],
          "organisations" => ["my-org-id"],
        },
      }
      expect(payload).to match a_hash_including(payload_hash)
    end

    it "converts role appointment links to role and person links" do
      role_appointment_id = SecureRandom.uuid
      role_appointments = build(:tag_field, type: "multi_tag", id: "role_appointments")
      document_type = build(:document_type, tags: [role_appointments])
      document = build(:document, document_type_id: document_type.id, tags: {
                         role_appointments: [role_appointment_id],
                       })

      person_id = SecureRandom.uuid
      role_id = SecureRandom.uuid
      publishing_api_has_links(
        "content_id" => role_appointment_id,
        "links" => { "person" => [person_id], "role" => [role_id] },
      )

      payload = PublishingApiPayload.new(document).payload

      expect(payload["links"]).to match a_hash_including(
        "roles" => [role_id],
        "people" => [person_id],
      )
    end

    it "transforms Govspeak before sending it to the publishing-api" do
      body_field = build(:field, type: "govspeak", id: "body")
      document_type = build(:document_type, contents: [body_field])
      document = build(:document, document_type_id: document_type.id, contents: { body: "Hey **buddy**!" })

      payload = PublishingApiPayload.new(document).payload

      expect(payload["details"]["body"]).to eq("<p>Hey <strong>buddy</strong>!</p>\n")
    end

    it "includes a lead image if present" do
      image = build(:image, alt_text: "image alt text", caption: "image caption", asset_manager_file_url: "http:://assets-manager.gov.uk/image.jpg")
      document_type = build(:document_type, lead_image: true)
      document = build(:document, document_type_id: document_type.id, lead_image: image)

      payload = PublishingApiPayload.new(document).payload

      payload_hash = {
        "url" => "http:://assets-manager.gov.uk/image.jpg",
        "alt_text" => "image alt text",
        "caption" => "image caption",
      }

      expect(payload["details"]["image"]).to match a_hash_including(payload_hash)
    end

    it "includes a change note if the update type is 'major'" do
      document = create(:document, update_type: "major", change_note: "A change note")
      payload = PublishingApiPayload.new(document).payload

      expect(payload).to match a_hash_including("change_note" => "A change note")
    end

    it "does not include a change note if the update type is 'minor'" do
      document = create(:document, update_type: "minor", change_note: "A change note")
      payload = PublishingApiPayload.new(document).payload

      expect(payload).not_to match a_hash_including("change_note" => "A change note")
    end
  end
end
