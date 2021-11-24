require 'test_helper'

describe 'routes/institutions/update' do
  it 'should update institution' do
    institution = create(:institution, id: 1, name: 'firm1')
    assert_nil institution.display_name
    post '/institutions/1', {display_name: "new_institution"}
    assert last_response.redirect?
    assert_equal 'new_institution', institution.reload.display_name
  end
end
