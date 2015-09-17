$:.push(File.expand_path('../lib', __FILE__))

require 'sinatra'
require 'slonos'
require 'pusher'

helpers do
  def spotify
    Spotify::Client.new({
      :raise_errors => true,

      # Connection properties
      :retries       => 0,
    })
  end

  def pusher
    Pusher::Client.new({
      app_id: ENV['PUSHER_APP_ID'],
      key: ENV['PUSHER_APP_KEY'],
      secret: ENV['PUSHER_APP_SECRET'],
    })
  end

  def say(text)
    JSON.dump({ text: text })
  end
end

get '/' do
  "Sonos controller\n"
end

post '/slack_in' do
  return 403 unless params['token'] && params['token'] == ENV['SLACK_TOKEN']
  return 400 unless params['text']

  match = /\\([^ ]+) ?(.*)?/.match(params['text'])

  return say('Unrecognised command') unless match

  subcommand = match[1]
  case subcommand
  when 'play'
    pusher.trigger('commands', 'play', {})
  when 'pause'
    pusher.trigger('commands', 'pause', {})
  when 'vol', 'volume'
    case match[2]
    when 'up'
      pusher.trigger('commands', 'volume-up', {})
    when 'down'
      pusher.trigger('commands', 'volume-down', {})
    else
      return say("Unrecognised volume instruction #{match[2]}")
    end
  when 'louder'
    pusher.trigger('commands', 'volume-up', {})
  when 'quieter'
    pusher.trigger('commands', 'volume-down', {})
  when 'cancel', 'remove'
    pusher.trigger('commands', 'remove', {})
  when 'add'
    term = match[2]
    return say('No search term!') unless term

    results = spotify.search(:track, term)

    return say('Sorry, nothing found') unless results['tracks']

    track = Slonos::SpotifyTrack.new(results['tracks']['items'][0])

    pusher.trigger(
      'commands',
      'add',
      {
        id: track.id,
        name: track.name
      }
    )

    return say("Queued #{track.name} from #{track.album_name} by #{track.artist_name}")
  else
    return say("Unrecognised subcommand '#{subcommand}'")
  end

  return 201
end

post '/pusher_auth' do
  return 403 unless params['client_token'] && params['client_token'] == ENV['CLIENT_TOKEN']
  return 403 unless params['channel'] == 'private-commands'

  return JSON.dump(
    pusher['private-commands'].authenticate(params['socket_id'])
  )
end

post '/say' do
  return 403 unless params['client_token'] && params['client_token'] == ENV['CLIENT_TOKEN']
  return 400 unless params['text']

  body = {
    text: params['text']
  }

  body[:channel] = params['channel'] if params['channel']

  response = Excon.post(
    ENV['SLACK_WEBHOOK_URL'],
    headers: { 'Content-Type' => 'application/json' },
    body: JSON.dump(body)
  )

  return response.status
end
