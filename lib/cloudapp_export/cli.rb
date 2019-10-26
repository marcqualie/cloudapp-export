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
    option :cache, type: :boolean, default: false
    def all
      authenticate!

      items = CloudappExport::ItemList.new(
        api,
        'limit' => options['limit'],
        'use_cache' => options['cache'],
        'cache_key' => "#{username}:#{options['limit']}",
      )
      say("Account contains #{set_color items.total_count, :bold} items")
      say("", nil, true)

      exporter = ::CloudappExport::Exporter.new(
        items,
        'dir' => options['dir'],
      )
      exporter.on_log do |message|
        print message
      end
      exporter.export_all
    end

    # rubocop:disable Metrics/AbcSize
    desc :stats, "Show stats for CloudApp items"
    option :dir, default: "#{ENV['HOME']}/Downloads/CloudappExport", type: :string, desc: "Directory where your files were downloaded to"
    option :cache, type: :boolean, default: false
    def stats
      authenticate!

      items = CloudappExport::ItemList.new(
        api,
      )
      say("Account contains #{set_color items.total_count, :bold} items")
      say("", nil, true)

      say("Dir         #{options['dir']}")
      say("", nil, true)

      # TODO: Just count files directly in local folder
      downloaded_items = items.data.select { |item| File.exist?("#{options['dir']}/#{item.filename}") }
      downloaded_items_size = downloaded_items.inject(0) { |sum, item| sum + File.size("#{options['dir']}/#{item.filename}") }

      say("Downloaded  #{downloaded_items.count}")
      say("            #{(downloaded_items_size.to_f / 1_000_000).round 2} mb")
    end
    # rubocop:enable Metrics/AbcSize

    # rubocop:disable Metrics/BlockLength
    no_commands do
      def api
        @api ||= begin
          CloudappExport::Api.new(
            'username' => username,
            'password' => password,
          )
        end
      end

      def authenticate!
        api.authenticate!
        say("Successfully authenticated!", :green)
      rescue StandardError => e
        say("Could not authenticate with Cloudapp (#{e.message})", :red)
        Kernel.exit
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
          (password ||= ask("Password:", echo: false)) && say('*' * 20)
          password || raise("Password is required")
        end
      end
    end
    # rubocop:enable Metrics/BlockLength
  end
end
