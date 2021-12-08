require 'test_helper'

describe 'routes/jin10/messages' do
  it 'return jin10 messages' do
    create(:jin10_message)
    get '/jin10-messages'
    assert last_response.ok?
  end
end
