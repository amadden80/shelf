
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

end
