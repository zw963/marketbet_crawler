require 'test_helper'

describe 'routes/insiders/index' do
  it 'return all insiders' do
    create(:insider)
    get '/insiders'
    assert last_response.ok?
  end

  it 'return all insiders for specified page/per' do
    5.times { create(:insider) }
    get '/insiders', {'page' => 3, 'per' => 1}
    assert last_response.ok?
  end

  it 'search insiders use name' do
    create(:insider, name: 'insider1')
    get '/insiders', {'name' => 'insider1'}
    assert last_response.ok?
  end
end
