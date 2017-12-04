require 'json'
require 'net/http'
require 'net/http/digest_auth'
require 'open-uri'
require 'uri'

module CloudappExport
  class Api
    DEFAULT_HOST = "my.cl.ly"

    def initialize(options = {})
      @options = options
    end

    def request(path)
      digest_auth = Net::HTTP::DigestAuth.new
      uri = URI.parse("https://#{host}/v3/#{path}")
      uri.user = CGI.escape(username)
      uri.password = password

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        # First request is a 401 response with a WWW-Authenticate header
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        # Create a new request with the Authorization header
        auth = digest_auth.auth_header(uri, response['www-authenticate'], 'GET')
        request = Net::HTTP::Get.new(uri.request_uri)
        request.add_field('Authorization', auth)

        # re-issue request with Authorization
        ApiResponse.new(http.request request)
      end
    end

    protected

    def host
      @options['host'] || DEFAULT_HOST
    end

    def username
      @options['username'] || raise('Username is required for API use')
    end

    def password
      @options['password'] || raise('Password is required for API use')
    end
  end

  class ApiResponse
    def initialize(http_response)
      @http_response = http_response
    end

    def body
      @http_response.body
    end

    def data
      JSON.parse(@http_response.body)['data']
    end
  end
end
