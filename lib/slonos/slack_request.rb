module Slonos
  class SlackRequest
    # Body, expected token for validation
    def initialize(body, token = nil)
      @body = body
      @token = token
    end

    def parse
      @parsed ||= Hash[ URI.decode_www_form(@body) ]
      raise 'Invalid request' if @token && (@parsed['token'] != @token)
    end

    def message
      parse['text']
    end
  end
end
