require './shelf'

Shelf.new(2345).serve do |request|

      # This should be replaced with your own router
      # If success! Return the html string that should be rendered
      # If fail! return nil... a 404 will be returned

  html = File.read('./views/index.html')
  message = request.params['message'] || "Welcome"
  html.gsub("{{ body_string }}", message)

end
