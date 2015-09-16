#!/usr/bin/env ruby

require 'spotify-client'

puts JSON.dump Spotify::Client.new({
  :raise_errors => true,

  # Connection properties
  :retries       => 0,
}).search(:track, ARGV.join(' '))