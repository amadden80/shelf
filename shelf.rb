require 'pry'
require 'socket'

class Shelf

  def initialize(port)
    @port = port
    @server = TCPServer.new(port)
  end

  def serve()

    puts "                           listening on port #{ @port }..."

    loop do
      Thread.start(@server.accept) do |client|
        puts "                           +++  #{Time.now} +++"

        request = Request.new(client)
        puts request

        unless ["/favicon.ico"].flatten.include? request.uri


          if Dir["./public/*"].include?("./public"+ request.uri)
            filename = "./public/"+ request.uri
            response_body = File.read(filename)
            response_type = filename.split('.').last || 'plain'
          else
            response_body = yield request
            response_type = 'html'
          end

          if response_body
            header =  [
                        "HTTP/1.1 200 OK",
                        "Content-Type: text/#{ response_type }; charset=utf-8",
                        "Content-Length: #{ response_body.length }",
                        ""
                      ].join("\n")

            response = header + "\n" + response_body
          else
            response = "HTTP/1.1 404 Not Found SRY"
          end

          client.puts response

        end

        client.close

        puts "                           ---  #{Time.now}  ---"
      end
    end
  end

end




class Request
  attr_reader :method, :uri, :protocol, :header, :cookies, :params, :body
  def initialize(request_client)

    @method, @uri, @protocol = request_client.gets.chomp.split(' ')
    @header = read_parse_http_header(request_client)
    @cookies = parse_key_equal_value(@header['Cookie'])
    @params = {}

    url_params = parse_key_equal_value(@uri.split("?")[1])
    @params.merge!(url_params)

    if @method == 'POST'
      @body = request_client.read(@header['Content-Length'].to_i)
      if boundary = @header['Content-Type'].scan(/boundary=([^\r\n;]+)/).flatten.first
        body_params = parse_boundary_form_data(@body, boundary)
      else
        body_params = parse_key_equal_value(@body)
      end
      @params.merge!(body_params)
    end

  end

  def parse_key_equal_value(string)
    parsed = {}
    if string
      string.scan(/([^= ;&]+)=([^= ;&]+)/).each do |pair|
        key = pair[0]
        value = pair[1]
        parsed[key.to_s]=value
        parsed[key.to_sym]=value
      end
    end
    parsed
  end

  def parse_boundary_form_data(string, boundary)
    parsed = {}
    raw = string.split(boundary) - ["", "--", "--\r\n"]
    raw.each do |item|
      key_info, value = item.split("\r\n") - ["", "--", "--\r\n"]
      key = key_info.scan(/name=(.*)/).flatten.first.gsub("\"", '')
      parsed[key.to_s] = value
      parsed[key.to_sym] = value
    end
    parsed
  end

  def read_parse_http_header(request_client)
    header = {}
    while true
       line = request_client.gets
       break if line == "\r\n"
       line.chomp!
       label, value = line.split(':')
       header[label] = value
    end
    header
  end

  def to_s
    "#{@method}:  #{@uri}"
  end

end
