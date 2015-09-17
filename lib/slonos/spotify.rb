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

  class SpotifyTrack
    def initialize(track_from_spotify_api)
      @data = track_from_spotify_api
    end

    def id
      @data['id']
    end

    def name
      @data['name']
    end

    def album_name
      @data['album']['name']
    end

    def album_id
      @data['album']['id']
    end

    def artist_name
      @data['artists'].map { |a| a['name'] }.join(', ')
    end
  end
end
