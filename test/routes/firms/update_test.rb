require 'test_helper'

describe 'routes/institutions/update' do
  it 'should update institution' do
    institution = create(:institution, id: 1, name: 'institution1')
    assert_equal 'institution1', institution.display_name
    post '/institutions/1', {display_name: "new_institution"}
    assert last_response.redirect?
    assert_equal "institution1 (new_institution)", institution.reload.display_name
  end
end
