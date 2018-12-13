# frozen_string_literal: true

class ImageUpdateParams
  attr_reader :image

  def initialize(image)
    @image = image
  end

  def call(params)
    params["filename"] = normalise_filename(params["filename"])
    params["filename"] = ensure_unique_name(params["filename"])
    params
  end

private

  def normalise_filename(name)
    filename = ActiveStorage::Filename.new(name)
    extension = Rack::Mime::MIME_TYPES.invert[image.blob.content_type]
    "#{filename.base.parameterize}#{extension}"
  end

  def ensure_unique_name(name)
    return name if is_unique_filename?(name)

    filename = ActiveStorage::Filename.new(name)
    count = 1

    loop do
      name = "#{filename.base}-#{count}.#{filename.extension}"
      return name if is_unique_filename?(name)
    end
  end

  def is_unique_filename?(name)
    image.document.images
      .where(filename: name)
      .where.not(id: image.id).none?
  end
end
