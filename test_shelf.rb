require 'net/http'
require 'test/unit'
require './lib/shelf'

class TestShelf<  Test::Unit::TestCase

  def setup
    @port = 2345
    @server = Shelf.new(@port)

    # ****************************************************
    # ** This will be the routers processors **
    processor = Proc.new { File.read('./views/index.html') }
    # ****************************************************

    @server_thread = Thread.new { @server.serve &processor }
  end

  def teardown
    @server_thread.exit
  end

  def test_get_root
    url = URI.parse("http://localhost:#{@port}")
    req = Net::HTTP::Get.new(url)
    res = Net::HTTP.start(url.host, url.port) {|http| http.request(req)}
    assert_equal(res.code, "200", "root response with code 200")
  end

end
