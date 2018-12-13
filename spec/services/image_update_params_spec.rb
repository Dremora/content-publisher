# frozen_string_literal: true

RSpec.describe ImageUpdateParams do
  describe "#call" do
    it "parameterises the base filename" do
      image = build(:image)
      params = { "filename" => "File $ name.jpg" }
      result = ImageUpdateParams.new(image).call(params)
      expect(result["filename"]).to eq "file-name.jpg"
    end

    it "enforces an extension for the filename" do
      image = create(:image, fixture: "animated-gif.gif")
      params = { "filename" => "file.jpg" }
      result = ImageUpdateParams.new(image).call(params)
      expect(result["filename"]).to eq "file.gif"
    end

    it "ensures the filename is unique" do
      document = create(:document)
      image1 = create(:image, document: document)
      image2 = create(:image, document: document, filename: "name.jpg")
      image3 = create(:image, filename: "name-1.jpg")
      params = { "filename" => "name.jpg" }
      result = ImageUpdateParams.new(image1).call(params)
      expect(result["filename"]).to eq "name-1.jpg"
    end
  end
end
