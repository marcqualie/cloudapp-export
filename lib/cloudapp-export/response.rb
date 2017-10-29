module CloudappExport
  class Response
    def initialize(http_response)
      @http_response = http_response
    end

    def body
      @http_response.body
    end

    def data
      JSON.parse(@http_response.body)['data']
    end
  end
end
