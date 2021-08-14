class TestDom < Snabberb::Component

  def render
    table = [
      {
        name: '张三',
        age: '20',
        address: '北京'
      },
      {
        name: '李四',
        age: '21',
        address: '武汉'
      },
      {
        name: '王五',
        age: '22',
        address: '杭州'
      }
    ]
  end
end
