require 'test_helper'

describe 'routes/institutions/show' do
  it 'should return institution' do
    institution = create(:institution, id: 1)
    get '/institutions/1'
    refute last_response.ok?
    create(:institution_history, institution: institution)
    get '/institutions/1'
    assert last_response.ok?
  end
end
