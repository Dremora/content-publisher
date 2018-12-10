# frozen_string_literal: true

module Requirements
  class ExplanatoryNoteChecker
    EXPLANATORY_NOTE_MAX_LENGTH = 600

    attr_reader :explanatory_note

    def initialize(explanatory_note)
      @explanatory_note = explanatory_note
    end

    def pre_retirement_issues
      issues = []

      if explanatory_note.blank?
        issues << Issue.new(:explanatory_note, :blank)
      end

      if explanatory_note.to_s.size > EXPLANATORY_NOTE_MAX_LENGTH
        issues << Issue.new(:explanatory_note, :too_long, max_length: EXPLANATORY_NOTE_MAX_LENGTH)
      end

      CheckerIssues.new(issues)
    end
  end
end
