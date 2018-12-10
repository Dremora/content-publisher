# frozen_string_literal: true

RSpec.feature "Document retirement requirements" do
  scenario do
    given_there_is_a_published_document
    given_i_have_the_managing_editor_permission
    when_i_visit_the_document_retirement_page
    and_i_click_save
    then_i_see_an_error_to_enter_an_explanatory_note

    when_i_enter_an_explanatory_note_that_is_too_long
    and_i_click_save
    then_i_see_an_error_to_enter_a_shorter_explanatory_note
  end

  def given_there_is_a_published_document
    @document = create(:document, :published)
  end

  def given_i_have_the_managing_editor_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions + [User::MANAGING_EDITOR_PERMISSION])
  end

  def when_i_visit_the_document_retirement_page
    visit retire_document_path(@document)
  end

  def and_i_click_save
    click_on "Save"
  end

  def then_i_see_an_error_to_enter_an_explanatory_note
    within(".gem-c-error-summary") do
      expect(page).to have_content(I18n.t!("requirements.explanatory_note.blank.form_message"))
    end
  end

  def when_i_enter_an_explanatory_note_that_is_too_long
    fill_in "explanatory_note", with: "a" * (Requirements::ExplanatoryNoteChecker::EXPLANATORY_NOTE_MAX_LENGTH + 1)
  end

  def then_i_see_an_error_to_enter_a_shorter_explanatory_note
    within(".gem-c-error-summary") do
      expect(page).to have_content(
        I18n.t!(
          "requirements.explanatory_note.too_long.form_message",
          max_length: Requirements::ExplanatoryNoteChecker::EXPLANATORY_NOTE_MAX_LENGTH,
        ),
      )
    end
  end
end
