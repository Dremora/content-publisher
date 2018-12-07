# frozen_string_literal: true

class ImageUpdateService
  CROP_ATTRIBUTES = %w[crop_x crop_y crop_width crop_height]

  attr_reader :image

  def initialize(image)
    @image = image
  end

  def call
    if update_in_asset_manager?
      AssetManagerService.new.update_bytes(image, image.cropped_bytes)
    end

    image.save!
  end

private

  def update_in_asset_manager?
    (image.changed_attributes.keys & CROP_ATTRIBUTES).any?
  end
end
