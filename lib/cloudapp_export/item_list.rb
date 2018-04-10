require "json"
require "digest"

module CloudappExport
  class ItemList
    def initialize(api, options = {})
      @api = api
      @items = []
      @cache_key = options['cache_key']
      @use_cache = options['use_cache']
      @limit = (options['limit'] || 999_999_999).to_i
      @offset = (options['offset'] || 0).to_i
    end

    def data
      load
      @items
    end

    def count
      [total_count, @limit].min
    end

    def total_count
      load_meta
      @meta['count'].to_i
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
    attr_writer :limit

    protected

    def load
      @items = begin
        if @use_cache && File.exist?(cache_file_path)
          items = ::JSON.parse(::File.read(cache_file_path))
        else
          response = @api.request("items?per_page=#{@limit}")
          items = response.data
          ::File.write(cache_file_path, ::JSON.dump(items)) if @cache_key
        end
        items.map do |attributes|
          ::CloudappExport::Item.new(attributes)
        end
      end
    end

    def load_meta
      @load_meta ||= begin
        response = @api.request("items?per_page=1")
        @meta = response.meta
      end
    end

    def cache_file_path
      hashed_cache_key = Digest::MD5.hexdigest(@cache_key)
      "/tmp/cloudapp-export-items-cache-#{hashed_cache_key}.json"
    end
  end
end
