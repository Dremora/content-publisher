# frozen_string_literal: true

RSpec.describe Requirements::ExplanatoryNoteChecker do
  describe "#pre_retirement_issues" do
    let(:max_length) { Requirements::ExplanatoryNoteChecker::EXPLANATORY_NOTE_MAX_LENGTH }

    it "returns no issues if there are none" do
      explanatory_note = "a" * max_length
      issues = Requirements::ExplanatoryNoteChecker.new(explanatory_note).pre_retirement_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue if there is no explanatory note" do
      issues = Requirements::ExplanatoryNoteChecker.new(nil).pre_retirement_issues

      message = issues.items_for(:explanatory_note).first[:text]
      expect(message).to eq(I18n.t!("requirements.explanatory_note.blank.form_message"))
    end

    it "returns an issue if the explanatory note is too long" do
      explanatory_note = "a" * (max_length + 1)
      issues = Requirements::ExplanatoryNoteChecker.new(explanatory_note).pre_retirement_issues

      message = issues.items_for(:explanatory_note).first[:text]
      expect(message).to eq(I18n.t!("requirements.explanatory_note.too_long.form_message", max_length: max_length))
    end
  end
end
