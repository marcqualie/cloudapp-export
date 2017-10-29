require 'net/http'
require 'net/http/digest_auth'
require 'open-uri'
require 'uri'

module CloudappExport
  class Request
    def initialize(path)
      @path = path
    end

    def request
      digest_auth = Net::HTTP::DigestAuth.new
      uri = URI.parse("https://#{ENV['CLOUDAPP_API_HOST']}/v3/#{@path}")
      uri.user = CGI.escape(ENV['CLOUDAPP_USERNAME'])
      uri.password = ENV['CLOUDAPP_PASSWORD']

      Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        # First request is a 401 response with a WWW-Authenticate header
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        # Create a new request with the Authorization header
        auth = digest_auth.auth_header(uri, response['www-authenticate'], 'GET')
        request = Net::HTTP::Get.new(uri.request_uri)
        request.add_field('Authorization', auth)

        # re-issue request with Authorization
        Response.new(http.request request)
      end
    end
  end
end
