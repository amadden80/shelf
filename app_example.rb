require './shelf'


Shelf.new(2345).serve do |request|

  html = File.read('./views/index.html')

  binding.pry
  # request.params

  html.gsub("{{ body_string }}", 'Yo')

end
