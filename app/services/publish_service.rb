# frozen_string_literal: true

class PublishService
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def publish(review_state)
    publish_assets(document.images)

    # Sending update_type in .publish is deprecated (should be in payload instead)
    GdsApi.publishing_api_v2.publish(document.content_id, nil, locale: document.locale)

    document.update!(
      publication_state: "sent_to_live",
      has_live_version_on_govuk: true,
      review_state: review_state,
      live_state: "published",
    )
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    document.update!(publication_state: "error_sending_to_live")
    raise
  end

private

  def publish_assets(assets)
    assets.each do |asset|
      AssetManagerService.new.publish(asset)
      asset.update!(publication_state: "live")
    end
  end
end
