require "fileutils"
require "thor"

module CloudappExport
  class CLI < Thor
    desc :all, "Export all data"
    option :limit, default: 5, type: :numeric
    option :dir, default: "#{ENV['HOME']}/Downloads/CloudappExport", type: :string
    def all
      file_path = "../../items.json"
      items = begin
        if File.exist?(file_path)
          items = JSON.parse(File.read(file_path))
        else
          request = CloudappExport::Request.new("items?per_page=1000")
          response = request.request
          items = response.data
          File.write(file_path, JSON.pretty_generate(items))
        end
        items.map { |attributes| Item.new(attributes) }
      end
      items = items.take(options['limit'])

      items_dir = options['dir']
      FileUtils.mkdir_p(items_dir) unless Dir.exist?(items_dir)

      items_count = items.count
      items.each do |item, index|
        filepath = "#{items_dir}/#{item.filename}"
        exists = File.exist?(filepath)
        filesize = exists ? File.size(filepath) : 0

        puts ""
        puts "item:"
        puts "  #{item.name}"

        if exists
          puts "  #{item.filename}  #{filesize}b"
        else
          puts "  #{item.filename}  #{filesize}b"
          begin
            open(filepath, 'wb') do |file|
              file << open(item['remote_url']).read
            end
            puts "    [#{index.to_s.rjust(4, '0')} / #{items_count}] DL #{filepath}"
          rescue => error
            puts "    [#{index.to_s.rjust(4, '0')} / #{items_count}] ER #{filepath}   #{error.message}"
            puts "              #{item['remote_url']}"
            puts "              #{item}"
          end
        end
      end
    end
  end
end
