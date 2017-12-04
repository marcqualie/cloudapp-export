require "fileutils"
require "thor"

module CloudappExport
  class CLI < Thor
    desc :all, "Export all data"
    option :limit, default: 5, type: :numeric
    option :dir, default: "#{ENV['HOME']}/Downloads/CloudappExport", type: :string
    def all
      items = CloudappExport::ItemList.new(api, {
        'limit' => options['limit'],
      })

      exporter = ::CloudappExport::Exporter.new(items, {
        'dir' => options['dir'],
      })
      exporter.on_log do |message|
        print "#{message}"
      end
      exporter.export_all
    end

    no_commands do
      def api
        @_api ||= CloudappExport::Api.new(
          'username' => ENV['CLOUDAPP_USERNAME'],
          'password' => ENV['CLOUDAPP_PASSWORD'],
        )
      end
    end
  end
end
