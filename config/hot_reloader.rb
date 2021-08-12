require 'hot_reloader'

loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/../app")
loader.push_dir("#{__dir__}/../app/models")
loader.push_dir("#{__dir__}/../app/services")
loader.ignore("#{__dir__}/../app/ar")
loader.collapse("#{__dir__}/../app/parsers")
loader.inflector.inflect "ar" => "AR"

puts '5'*100
loader.setup
puts '6'*100
