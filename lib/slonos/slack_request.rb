module Slonos
  class SlackRequest
    def initialize(body)
      @body = body
    end

    def parse
      @parsed ||= Hash[ URI.decode_www_form(@body) ]
    end

    def message
      parse['text']
    end
  end
end
