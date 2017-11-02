RSpec.feature 'Linking and unlinking resources' do
  include_context "as a logged-in editor user"

  let!(:subject_resource) { create(:resource,title: 'Chrysler Building',organization: user_organization) }
  let!(:object_resource)  { create(:resource,title: 'Picture of Chrysler Building',organization: user_organization) }

  scenario 'succeeds' do
    visit resource_path(subject_resource)

    click_first_link('Create Link to Another Resource')

    expect(page.current_path).to eq(new_resource_link_path)

    select('hasVersion',from: 'Verb')
    select(object_resource.label,from: 'Object resource')

    expect {
      click_button('Save')
    }.to change(ResourceLink,:count).
      from(0).to(1)

    resource_link = ResourceLink.first
    expect(page.current_path).to eq(resource_link_path(resource_link))

    expect(object_resource.object_resource_links.size).to eq(1)
    expect(subject_resource.subject_resource_links.size).to eq(1)

    click_link 'Edit'
    expect(page.current_path).to eq(edit_resource_link_path(resource_link))

    select('hasFormat',from: 'Verb')

    expect {
      click_button('Save')
      resource_link.reload
    }.to change(resource_link,:verb).
      from('hasVersion').to('hasFormat')

    expect(page.current_path).to eq(resource_link_path(resource_link))

    expect {
      click_link('Delete')
    }.to change {
      ResourceLink.exists?(resource_link.id)
    }.from(true).to(false)

    expect(page.current_path).to eq(resource_path(subject_resource))
  end
end
