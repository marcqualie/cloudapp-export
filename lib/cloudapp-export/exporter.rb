module CloudappExport
  class Exporter
    attr_reader :items

    def initialize(items, options = {})
      @items = items
      @options = options
      @log_callbacks = []
    end

    def export_all
      FileUtils.mkdir_p(download_dir) unless Dir.exist?(download_dir)

      items_count = items.count
      items.each_with_index do |item, index|
        percent = (index + 1).to_f / items_count * 100
        log "[#{(index + 1).to_s.rjust(4, '0')} / #{items_count.to_s.rjust(4, '0')}  #{percent.round.to_s.rjust(3, ' ')}%]"
        export_item(item)
      end
    end

    def export_item(item)
      log "  #{item.name} -> #{item.filename}".ljust(80, ' ')

      filepath = "#{download_dir}/#{item.filename}"
      if File.exist?(filepath)
        log "  SK  #{item_filesize_human(item)}"
      else
        begin
          log "  DL"
          open(filepath, 'wb') do |file|
            file << open(item['remote_url']).read
          end
          log "  #{item_filesize_human(item)}"
        rescue StandardError => error
          log "  ER #{error.message}"
        end
      end
      log "\n"
    end

    def on_log(&block)
      @log_callbacks.push(block)
    end

    protected

    def item_filesize(item)
      filepath = "#{download_dir}/#{item.filename}"
      File.exist?(filepath) ? File.size(filepath) : 0
    end

    def item_filesize_human(item)
      filesize = item_filesize(item)
      return '--' if filesize.zero?
      size_human(filesize)
    end

    def size_human(filesize)
      filesize >= (1024 * 1024) \
        ? "#{(filesize.to_f / (1024 * 1024)).round 2} mb"
        : "#{(filesize.to_f / 1024).round 2} kb"
    end

    def log(message)
      @log_callbacks.each do |callback|
        callback.call(message)
      end
    end

    def download_dir
      @options['dir']
    end
  end
end
