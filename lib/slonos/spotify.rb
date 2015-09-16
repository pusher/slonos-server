require 'spotify-client'

module Slonos
  module Spotify

    def self.client
      @client ||= ::Spotify::Client.new({
        :raise_errors => true,

        # Connection properties
        :retries       => 0,
      })
    end

  end
end
