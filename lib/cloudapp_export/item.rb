module CloudappExport
  class Item
    attr_reader :attributes

    def initialize(attributes)
      @attributes = attributes
    end

    def [](key)
      @attributes[key]
    end

    def name
      @attributes['name']
    end

    def filename
      ext = @attributes['name'].split('.').last
      "#{@attributes['slug']}.#{ext}"
    end
  end
end
