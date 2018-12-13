# frozen_string_literal: true

class ImageUpdateService
  CROP_ATTRIBUTES = %w[crop_x crop_y crop_width crop_height].freeze

  attr_reader :image

  def initialize(image)
    @image = image
  end

  def call
    if image.publication_state == "live"
      raise "Cannot edit live images"
    end

    if filename_changed?
      image.blob.update!(filename: image.filename)
    end

    if need_to_update_asset_manager?
      image.asset_manager_file_url = update_in_asset_manager(image)
    end

    image.save!
  end

private

  def update_in_asset_manager(image)
    AssetManagerService.new.update_bytes(image, image.cropped_bytes)
  end

  def need_to_update_asset_manager?
    return true if filename_changed?
    (image.changed_attributes.keys & CROP_ATTRIBUTES).any?
  end

  def filename_changed?
    image.changed_attributes.keys.include?("filename")
  end
end
