require 'pry'
require 'socket'
require './request'

# Server
class Shelf
  def initialize(port)
    @port = port
    @server = TCPServer.new(port)
  end

  def serve()

    puts "                                listening on port #{ @port }..."

    loop do
      Thread.start(@server.accept) do |client|
        puts "                                +++  #{Time.now} +++"

        load './request.rb'
        request = Request.new(client)

        unless ["/favicon.ico"].include? request.uri

          response_html = yield request

          header =  [
                      "HTTP/1.1 200 OK",
                      "Content-Type: text/html; charset=utf-8",
                      "Content-Length: #{ response_html.length }",
                      ""
                    ].join("\n")

          response = header + "\n" + response_html

          client.puts response

        end

        client.puts 'hi'
        client.close

        puts "                                ---  #{Time.now}  ---"
      end
    end
  end

end


