require 'pry'
require 'socket'

# Server
class Shelf
  def initialize(port)
    @port = port
    @server = TCPServer.new(port)
  end

  def serve(&block)

    puts "                                listening on port #{ @port }..."

    loop do
      Thread.start(@server.accept) do |client|
        puts "                                +++  #{Time.now} +++"

        verb, path, protocol = client.gets.chomp.split(' ')

        response_html = block.call()

        header =  [
                    "HTTP/1.1 200 OK",
                    "Content-Type: text/xml; charset=utf-8",
                    "Content-Length: #{ response_html.length }",
                    ""
                  ].join("\n")

        response = header + "\n" + response_html

        client.puts response
        client.close

        puts "                                ---  #{Time.now}  ---"
      end
    end
  end

end

