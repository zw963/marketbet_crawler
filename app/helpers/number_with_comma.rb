module Helpers
  module_function

  def number_with_comma(number, space: 4)
    return '' if number.nil?

    int, dec = number.to_s.split('.')
    int = int.gsub(/\B(?=(#{"." * space})*\b)/, ',')
    int = "#{int}.#{dec}" unless dec.nil?
    int
  end
end
