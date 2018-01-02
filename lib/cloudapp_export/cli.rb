require "base64"
require "fileutils"
require "thor"

module CloudappExport
  class CLI < Thor
    class_option :auth, type: :string, description: "Base64 encoded username:password string"

    desc :all, "Export all data"
    option :limit, default: 5, type: :numeric
    option :dir, default: "#{ENV['HOME']}/Downloads/CloudappExport", type: :string
    option :cache, type: :boolean, default: true
    def all
      items = CloudappExport::ItemList.new(
        api,
        'limit' => options['limit'],
        'cache' => options['cache'],
      )

      exporter = ::CloudappExport::Exporter.new(
        items,
        'dir' => options['dir'],
      )
      exporter.on_log do |message|
        print message
      end
      exporter.export_all
    end

    desc :stats, "Show stats for CloudApp items"
    option :dir, default: "#{ENV['HOME']}/Downloads/CloudappExport", type: :string
    option :cache, type: :boolean, default: true
    def stats
      items = CloudappExport::ItemList.new(
        api,
        'cache' => options['cache'],
      )

      downloaded_items = items.data.select { |item| File.exist?("#{options['dir']}/#{item.filename}") }
      downloaded_items_size = downloaded_items.sum { |item| File.size("#{options['dir']}/#{item.filename}") }

      say("Dir         #{options['dir']}")
      say("Count       #{items.count}")
      say("Downloaded  #{downloaded_items.count}   #{(downloaded_items_size.to_f / 1_000_000).round 2} mb")
    end

    desc :auth_token, "Generate auth string"
    option :username, type: :string
    option :password, type: :string
    def auth_token
      username = options['username'] || ask("Username:")
      password = options['password'] || ask("Password:", echo: false)
      say("\n\n") unless options['password']
      token = Base64.encode64("#{username}:#{password}")
      say(token)
    end

    no_commands do
      def api
        @_api ||= begin
          auth_token = Base64.decode64(options['auth'] || '')
          username, password = auth_token.split(':')
          CloudappExport::Api.new(
            'username' => (username || ENV['CLOUDAPP_USERNAME']),
            'password' => (password || ENV['CLOUDAPP_PASSWORD']),
          )
        end
      end
    end
  end
end
