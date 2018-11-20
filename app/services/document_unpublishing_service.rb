# frozen_string_literal: true

class DocumentUnpublishingService
  def retire(document, explanatory_note, locale: "en")
    GdsApi.publishing_api_v2.unpublish(document.content_id, type: "withdrawal", explanation: explanatory_note, locale: locale)
  end

  def remove(document, explanatory_note: nil)
    delete_assets(document.images)
    GdsApi.publishing_api_v2.unpublish(document.content_id, type: "gone", explanation: explanatory_note)
  end

  def remove_and_redirect(document, redirect_path)
    delete_assets(document.images)
    GdsApi.publishing_api_v2.unpublish(document.content_id, type: "redirect", alternative_path: redirect_path)
  end

private

  def delete_assets(assets)
    assets.each do |asset|
      AssetManagerService.new.delete(asset)
    end
  end
end
