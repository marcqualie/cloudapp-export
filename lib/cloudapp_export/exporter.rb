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
      elsif item['remote_url'].nil? || item['item_type'] == 'pending'
        log "  SK  No Remote URL"
      else
        begin
          log "  DL"
          copy_file(item['remote_url'], filepath)
          log "  #{item_filesize_human(item)}"
        rescue StandardError => e
          log "  ER #{e.message}\n"
          e.backtrace.each { |line| log "          #{line}\n" }
        end
      end
      log "\n"
    end

    def on_log(&block)
      @log_callbacks.push(block)
    end

    protected

    def copy_file(remote_url, local_path)
      remote_uri = URI.parse(URI.encode(remote_url, '[]'))
      File.open(local_path, 'wb') do |file|
        file << Net::HTTP.get(remote_uri)
      end
    rescue StandardError => e
      File.delete(local_path)
      raise e
    end

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
