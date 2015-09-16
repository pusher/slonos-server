module Slonos
  class SlackRequest
    def initialize(body)
      @body = body
    end

    def parse
      @parsed ||= Hash[ @body.lines.map { |l| l.split('=') } ]
    end

    def message
      parse['text']
    end
  end
end
