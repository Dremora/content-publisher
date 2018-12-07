# frozen_string_literal: true

require "mini_magick"

class ImageUploader
  def initialize(file)
    @file = file
  end

  def upload(document)
    blob = ActiveStorage::Blob.create_after_upload!(
      io: image_normaliser.normalised_file,
      filename: filename,
      content_type: Marcel::MimeType.for(file),
    )

    image = Image.new(image_attributes)
    image.document = document
    image.blob = blob
    image.asset_manager_file_url = upload_to_asset_manager(image)
    image.save!
    image
  end

private

  attr_reader :file

  def upload_to_asset_manager(image)
    AssetManagerService.new.upload_bytes(image, image.cropped_bytes)
  end

  def filename
    file.respond_to?(:original_filename) ? file.original_filename : File.basename(file)
  end

  def image_normaliser
    @image_normaliser ||= Normaliser.new(file.path)
  end

  def image_attributes
    dimensions = image_normaliser.dimensions
    cropper = CentreCropper.new(dimensions[:width],
                                dimensions[:height],
                                Image::WIDTH.to_f / Image::HEIGHT)
    {
      width: dimensions[:width],
      height: dimensions[:height],
      crop_x: cropper.dimensions[:x],
      crop_y: cropper.dimensions[:y],
      crop_width: cropper.dimensions[:width],
      crop_height: cropper.dimensions[:height],
      filename: filename,
    }
  end
end
