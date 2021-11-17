require 'test_helper'

describe 'routes/firms/show' do
  it 'should return firm' do
    firm = create(:firm, id: 1)
    get '/firms/1'
    refute last_response.ok?
    create(:institution, firm: firm)
    get '/firms/1'
    assert last_response.ok?
  end
end
