require 'dotenv'
require 'json'
require 'cloudapp-export'

namespace :cloudapp do
  desc "Export data from CloudApp"
  task :export do |_t, _args|
    Dotenv.load

    items = begin
      if File.exist?('items.json')
        items = JSON.parse(File.read('items.json'))
      else
        request = CloudappExport::Request.new('items?per_page=10000')
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
  end
end
