require 'bundler'
Bundler.setup

require 'dotenv'
Dotenv.load

require 'json'
require 'net/http'
require 'net/http/digest_auth'
require 'open-uri'
require 'uri'
require 'yaml'

module CloudApp
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

  class Response
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

items = begin
  if File.exist?('items.json')
    items = JSON.parse(File.read('items.json'))
  else
    request = CloudApp::Request.new('items?per_page=10000')
    response = request.request
    items = response.data
    File.write('items.json', JSON.pretty_generate(items))
  end
  items
end

items_count = items.count
item_files = Dir.glob('items/*')
items.each_with_index do |item, index|
  item_file = item_files.find { |file| file.index("#{item['slug']}-") == 0 } || "items/#{item['slug']}-#{item['name']}"
  exists = File.exist?(item_file)
  if exists && File.size(item_file) == 0
    puts "[#{index.to_s.rjust(4, '0')} / #{items_count}] 00 #{item_file}"
    File.delete(item_file)
    exists = false
  end
  if item_file['remote_url'].nil? || exists
    puts "[#{index.to_s.rjust(4, '0')} / #{items_count}] SK #{item_file}"
  else
    begin
      open(item_file, 'wb') do |file|
        file << open(item['remote_url']).read
      end
      puts "[#{index.to_s.rjust(4, '0')} / #{items_count}] DL #{item_file}"
    rescue => error
      puts "[#{index.to_s.rjust(4, '0')} / #{items_count}] ER #{item_file}   #{error.message}"
      puts "              #{item['remote_url']}"
      puts "              #{item}"
    end
  end
end
