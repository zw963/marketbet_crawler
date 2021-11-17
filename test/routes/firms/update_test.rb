require 'test_helper'

describe 'routes/firms/update' do
  it 'should update firm' do
    firm = create(:firm, id: 1, name: 'firm1')
    assert_nil firm.display_name
    post '/firms/1', {display_name: "new_firm"}
    assert last_response.redirect?
    assert_equal 'new_firm', firm.reload.display_name
  end
end
