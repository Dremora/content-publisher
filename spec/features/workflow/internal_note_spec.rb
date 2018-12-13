# frozen_string_literal: true

RSpec.feature "Displaying an internal note" do
  scenario do
    given_there_is_a_document_with_a_internal_note
    when_i_visit_the_document_page
    and_i_click_on_the_tab_document_history
    then_i_should_see_the_internal_note
  end

  def given_there_is_a_document_with_a_internal_note
    @document = create(:document, :publishable, base_path: "/news/belvita-soft-bakes")
    @timeline_entry = create(:timeline_entry, entry_type: "internal_note", document: @document)
    @internal_note = create(
      :internal_note,
      body: "Belvita's are pure joy",
      timeline_entry: @timeline_entry,
      document: @document,
    )
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def and_i_click_on_the_tab_document_history
    click_on "Document history"
  end

  def then_i_should_see_the_internal_note
    within("#document-history") do
      expect(page).to have_content(I18n.t!("documents.history.entry_types.internal_note"))
      expect(page).to have_content(@internal_note.body)
    end
  end
end
