# frozen_string_literal: true

RSpec.feature "Managing editor permissions" do
  scenario do
    given_there_is_a_published_document
    when_i_dont_have_the_managing_editor_permission
    when_i_visit_the_document_page
    then_i_cant_see_the_retire_button
    when_visit_the_retire_document_page
    then_i_see_a_permissions_error
    when_i_do_have_the_managing_editor_permission
    when_i_visit_the_document_page
    then_i_can_see_the_retire_button

    given_there_is_a_retired_document
    when_i_dont_have_the_managing_editor_permission
    when_i_visit_the_retired_document_page
    then_i_cant_see_the_update_explanatory_note_button
    when_i_do_have_the_managing_editor_permission
    when_i_visit_the_retired_document_page
    then_i_can_see_the_update_explanatory_note_button
  end

  def given_there_is_a_published_document
    @document = create(:document, :published)
  end

  def when_i_dont_have_the_managing_editor_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions - [User::MANAGING_EDITOR_PERMISSION])
  end

  def when_visit_the_retire_document_page
    visit retire_document_path(@document)
  end

  def when_i_visit_the_document_page
    visit document_path(@document)
  end

  def then_i_cant_see_the_retire_button
    expect(page).not_to have_content("Retire")
  end

  def then_i_see_a_permissions_error
    expect(page).to have_content(
      "Sorry, you don't seem to have the #{User::MANAGING_EDITOR_PERMISSION} permission for this app",
    )
  end

  def when_i_do_have_the_managing_editor_permission
    user = User.first
    user.update_attribute(:permissions,
                          user.permissions + [User::MANAGING_EDITOR_PERMISSION])
  end

  def then_i_can_see_the_retire_button
    expect(page).to have_content("Retire")
  end

  def given_there_is_a_retired_document
    create(:document, :retired)
  end

  def when_i_visit_the_retired_document_page
    visit document_path(Document.last)
  end

  def then_i_cant_see_the_update_explanatory_note_button
    expect(page).not_to have_content("Update reason for retiring")
  end

  def then_i_can_see_the_update_explanatory_note_button
    expect(page).to have_content("Update reason for retiring")
  end
end
