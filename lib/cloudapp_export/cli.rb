require "base64"
require "fileutils"
require "thor"

module CloudappExport
  class CLI < Thor
    class_option :username, type: :string, desc: "Account username"
    class_option :password, type: :string, desc: "Account password (not recommended to pass via command line)"

    desc :all, "Export all data from your Cloudapp account"
    option :limit, default: 5, type: :numeric
    option :dir, default: "#{ENV['HOME']}/Downloads/CloudappExport", type: :string, desc: "Directory to download all files to"
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
    option :dir, default: "#{ENV['HOME']}/Downloads/CloudappExport", type: :string, desc: "Directory where your files were downloaded to"
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

    no_commands do
      def api
        @api ||= begin
          CloudappExport::Api.new(
            'username' => username,
            'password' => password,
          )
        end
      end

      def username
        @username ||= begin
          username = options['username']
          username ||= ENV['CLOUDAPP_USERNAME']
          username ||= ask("Username:")
          username || raise("Username is required")
        end
      end

      def password
        say("WARNING: Passing password via the command line is not recommended!", :yellow) if options['password']
        @password ||= begin
          password = options['password']
          password ||= ENV['CLOUDAPP_PASSWORD']
          password ||= ask("Password:", echo: false)
          password || raise("Password is required")
        end
      end
    end
  end
end
