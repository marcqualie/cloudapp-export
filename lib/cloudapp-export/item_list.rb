require "json"

module CloudappExport
  class ItemList
    DEFAULT_LIMIT = 5

    def initialize(api, options = {})
      @api = api
      @items = []
      @use_cache = !!options['cache']
      @limit = (options['limit'] || DEFAULT_LIMIT).to_i
      @offset = (options['offset'] || 0).to_i
    end

    def count
      load
      [@items.count, @limit].min
    end

    def each(&block)
      load
      @items[@offset..(@limit - 1)].each(&block)
    end

    def each_with_index(&block)
      load
      @items[@offset..(@limit - 1)].each_with_index(&block)
    end

    # Restrict items to a subset from 0 to $number
    # @param number [Integer] Number of items to return
    # @return Integer
    def limit=(number)
      @limit = number
    end

    protected

    def load
      @items = begin
        if @use_cache && File.exist?(cache_file_path)
          items = ::JSON.parse(::File.read(cache_file_path))
        else
          response = @api.request("items?per_page=1000")
          items = response.data
          ::File.write(cache_file_path, ::JSON.pretty_generate(items))
        end
        items.map do |attributes|
          ::CloudappExport::Item.new(attributes)
        end
      end
    end

    def cache_file_path
      "#{ENV['HOME']}/.cloudapp-export-items.json"
    end
  end
end
