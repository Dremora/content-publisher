# frozen_string_literal: true

RSpec.feature "Retire a document" do
  scenario do
    given_there_is_a_published_document
    given_i_have_the_managing_editor_permission
    when_i_visit_the_document_page
    and_i_click_on_retire
    then_i_see_that_i_can_retire_the_document
    when_i_fill_in_the_explanatory_note
    and_click_on_save
    then_i_see_the_document_has_been_retired

    when_i_click_to_update_the_explanatory_note
    then_i_can_see_the_existing_explanatory_note
    then_i_can_edit_the_explanatory_note
  end

  def given_there_is_a_published_document
    @document = create(:document, :published)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def given_i_have_the_managing_editor_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions + [User::MANAGING_EDITOR_PERMISSION])
  end

  def and_i_click_on_retire
    click_on "Retire"
  end

  def then_i_see_that_i_can_retire_the_document
    expect(page).to have_content "Retire '#{@document.title}'"
  end

  def when_i_fill_in_the_explanatory_note
    fill_in "explanatory_note", with: "An explanation"
    expect(page).to have_content(I18n.t!("retire_document.retire.explanatory_note.guidance_title"))
    expect(page).to have_content(I18n.t!("retire_document.retire.explanatory_note.guidance"))
  end

  def and_click_on_save
    body = { type: "withdrawal", explanation: "An explanation", locale: @document.locale }
    stub_publishing_api_unpublish(@document.content_id, body: body)
    click_on "Save"
  end

  def then_i_see_the_document_has_been_retired
    timeline_entry = TimelineEntry.last
    expect(timeline_entry.entry_type).to eq("retired")
    expect(timeline_entry.document_id).to eq(@document.id)
    expect(timeline_entry.retirement.explanatory_note).to eq("An explanation")
    expect(@document.reload.live_state).to eq("retired")
    expect(page).to have_content(I18n.t!("user_facing_states.retired.name"))
  end

  def when_i_click_to_update_the_explanatory_note
    click_on "Update reason for retiring"
  end

  def then_i_can_see_the_existing_explanatory_note
    expect(page).to have_field("explanatory_note", with: Retirement.last.explanatory_note)
  end

  def then_i_can_edit_the_explanatory_note
    explanation = "A different explanation"
    body = { type: "withdrawal", explanation: explanation, locale: @document.locale }
    stub_publishing_api_unpublish(@document.content_id, body: body)
    fill_in "explanatory_note", with: explanation
    click_on "Save"
    expect(Retirement.last.explanatory_note).to eq(explanation)
  end
end
