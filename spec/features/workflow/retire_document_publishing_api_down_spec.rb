# frozen_string_literal: true

RSpec.feature "Retire a document when Publishing API is down" do
  scenario do
    given_there_is_a_published_document
    given_i_have_the_managing_editor_permission
    when_i_visit_the_retire_document_page
    and_the_publishing_api_is_down
    when_i_fill_in_the_explanatory_note
    and_click_on_save
    then_i_see_a_retirement_error_message
    and_the_document_has_not_been_retired
  end

  def given_there_is_a_published_document
    @document = create(:document, :published)
  end

  def given_i_have_the_managing_editor_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions + [User::MANAGING_EDITOR_PERMISSION])
  end

  def when_i_visit_the_retire_document_page
    visit retire_document_path(@document)
  end

  def and_the_publishing_api_is_down
    publishing_api_isnt_available
  end

  def when_i_fill_in_the_explanatory_note
    fill_in "explanatory_note", with: "An explanation"
  end

  def and_click_on_save
    click_on "Save"
  end

  def then_i_see_a_retirement_error_message
    expect(page).to have_content(I18n.t!("retire_document.retire.flashes.publishing_api_error.title"))
  end

  def and_the_document_has_not_been_retired
    expect(Retirement.count).to eq(0)
    expect(TimelineEntry.count).to eq(0)
    expect(Document.last.live_state).not_to eq("retired")
  end
end
