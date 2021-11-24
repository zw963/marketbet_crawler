require 'test_helper'

describe 'routes/institutions/update' do
  it 'should update institution' do
    institution = create(:institution, id: 1, name: 'firm1')
    assert_equal 'firm1', institution.display_name
    post '/institutions/1', {display_name: "new_institution"}
    assert last_response.redirect?
    assert_equal "firm1 (new_institution)", institution.reload.display_name
  end
end
