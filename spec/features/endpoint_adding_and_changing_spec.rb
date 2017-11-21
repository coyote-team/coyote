RSpec.describe 'Endpoint adding and changing' do
  include_context 'as a logged-in staff user'

  let!(:endpoint_to_change) { create(:endpoint,:website) }

  scenario 'succeeds' do
    click_first_link 'Endpoint Management (Staff)'
    expect(page.current_path).to eq(staff_endpoints_path)

    click_first_link 'Add New Endpoint'
    fill_in 'Name', with: 'Mobile App'

    expect {
      click_button 'Save'
    }.to change(Endpoint,:count).
      from(1).to(2)

    new_endpoint = Endpoint.find_by!(name: 'Mobile App')
    expect(page.current_path).to eq(staff_endpoint_path(new_endpoint))

    click_first_link 'Endpoint Management (Staff)'
    click_first_link endpoint_to_change.name
    expect(page.current_path).to eq(staff_endpoint_path(endpoint_to_change))

    click_first_link 'Edit'
    expect(page.current_path).to eq(edit_staff_endpoint_path(endpoint_to_change))

    fill_in 'Name', with: 'Special Device'

    expect {
      click_button 'Save'
      endpoint_to_change.reload
    }.to change(endpoint_to_change,:name).
      to('Special Device')

    expect(page.current_path).to eq(staff_endpoint_path(endpoint_to_change))

    expect {
      click_button 'Delete'
    }.to change { Endpoint.exists?(endpoint_to_change.id) }.
      from(true).to(false)

    expect(page.current_path).to eq(staff_endpoints_path)
  end
end
