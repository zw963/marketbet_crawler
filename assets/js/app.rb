require 'opal'
require 'snabberb'

puts 'hello'

class TextBox < Snabberb::Component
  needs :text
  needs :selected, default: false, store: true

  def render
    onclick = lambda do
      store(:selected, !@selected)
    end

    style = {
      cursor: 'pointer',
      border: 'solid 1px rgba(0,0,0,0.2)',
    }

    style['background-color'] = 'lightblue' if @selected

    h(:div, { style: style, on: { click: onclick } }, [
      h(:div, @text)
    ])
  end
end

TextBox.attach('app', text: 'hello world')
