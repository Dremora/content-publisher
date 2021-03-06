# frozen_string_literal: true

RSpec.describe UserFacingState do
  describe ".scope" do
    it "finds draft documents when they are not sent to review" do
      draft = create(:document,
                     publication_state: "sent_to_draft",
                     review_state: "unreviewed")
      create(:document, publication_state: "sent_to_draft", review_state: "submitted_for_review")

      expect(UserFacingState.scope(Document, "draft")).to match([draft])
    end

    it "finds submitted_for_review documents when they are sent to review" do
      create(:document, publication_state: "sent_to_draft", review_state: "reviewed")
      for_review = create(:document,
                          publication_state: "sent_to_draft",
                          review_state: "submitted_for_review")

      expect(UserFacingState.scope(Document, "submitted_for_review"))
        .to match([for_review])
    end

    it "finds published items including those marked as published_without_review" do
      create(:document, publication_state: "sent_to_draft", review_state: "unreviewed")
      published = create(:document,
                         publication_state: "sent_to_live",
                         review_state: "reviewed")
      published_but_needs_2i = create(:document,
                                      publication_state: "sent_to_live",
                                      review_state: "published_without_review")

      expect(UserFacingState.scope(Document, "published"))
        .to match([published, published_but_needs_2i])
    end

    it "can find published_but_needs_2i items" do
      create(:document, publication_state: "sent_to_live", review_state: "reviewed")
      published_but_needs_2i = create(:document,
                                      publication_state: "sent_to_live",
                                      review_state: "published_without_review")

      expect(UserFacingState.scope(Document, "published_but_needs_2i"))
        .to match([published_but_needs_2i])
    end

    it "finds nothing for an unknown state" do
      expect(UserFacingState.scope(Document, "surprise")).to be_empty
    end

    it "finds items that have been published and later retired" do
      create(:document, publication_state: "sent_to_live", live_state: "published")
      retired = create(:document, publication_state: "sent_to_live", live_state: "retired")

      expect(UserFacingState.scope(Document, "retired")).to match([retired])
    end

    it "finds items that have been published and later removed" do
      create(:document, publication_state: "sent_to_live", live_state: "published")
      removed = create(:document, publication_state: "sent_to_live", live_state: "removed")

      expect(UserFacingState.scope(Document, "removed")).to match([removed])
    end
  end

  describe "#to_s" do
    it "is draft if it has unpublished changes" do
      document = build(:document, publication_state: "changes_not_sent_to_draft", review_state: "unreviewed")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("draft")
    end

    it "is submitted_for_review if it has unpublished changes and 2i" do
      document = build(:document, publication_state: "changes_not_sent_to_draft", review_state: "submitted_for_review")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("submitted_for_review")
    end

    it "is draft if it has unpublished changes sent to draft" do
      document = build(:document, publication_state: "sent_to_draft")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("draft")
    end

    it "is draft if it has unpublished changes that we can't send to draft" do
      document = build(:document, publication_state: "error_sending_to_draft")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("draft")
    end

    it "is draft if in draft and we can't delete the draft" do
      document = build(:document, publication_state: "error_deleting_draft")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("draft")
    end

    it "is published_but_needs_2i if it has unreviewed changes sent to live" do
      document = build(:document, publication_state: "sent_to_live", review_state: "published_without_review")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("published_but_needs_2i")
    end

    it "is published if it has reviewed changes sent to live" do
      document = build(:document, publication_state: "sent_to_live", review_state: "reviewed")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("published")
    end

    it "is draft if the publishing failed" do
      document = build(:document, publication_state: "error_sending_to_live", review_state: "reviewed")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("draft")
    end

    it "is retired if it has been published and later retired" do
      document = build(:document, publication_state: "sent_to_live", live_state: "retired")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("retired")
    end

    it "is retired if it has not been reviewed and but has been retired" do
      document = build(
        :document,
        publication_state: "sent_to_live",
        review_state: "published_without_review",
        live_state: "retired",
      )

      state = UserFacingState.new(document).to_s

      expect(state).to eql("retired")
    end

    it "is removed if it has been published and later removed" do
      document = build(:document, publication_state: "sent_to_live", live_state: "removed")

      state = UserFacingState.new(document).to_s

      expect(state).to eql("removed")
    end

    it "is removed if it has not been reviewed and but has been removed" do
      document = build(
        :document,
        publication_state: "sent_to_live",
        review_state: "published_without_review",
        live_state: "removed",
      )

      state = UserFacingState.new(document).to_s

      expect(state).to eql("removed")
    end
  end
end
