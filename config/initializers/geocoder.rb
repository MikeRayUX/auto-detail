# frozen_string_literal: true

# Rails.configuration.mapbox = {
#   public_token: ENV['MAPBOX_PUBLIC_TOKEN']
# }
MAPBOX_PUBLIC_TOKEN = Rails.application.credentials.mapbox[:public_token]

Geocoder.configure(
  lookup: :mapbox,
  api_key: MAPBOX_PUBLIC_TOKEN,
  use_https: true, # use HTTPS for lookup requests? (if supported)
  # Geocoding options
  # timeout: 3,                 # geocoding service timeout (secs)
  # ip_lookup: :ipinfo_io,      # name of IP address geocoding service (symbol)
  # language: :en,              # ISO-639 language code
  # http_proxy: nil,            # HTTP proxy server (user:pass@host:port)
  # https_proxy: nil,           # HTTPS proxy server (user:pass@host:port)
  # cache: nil,                 # cache object (must respond to #[], #[]=, and #del)
  # cache_prefix: 'geocoder:',  # prefix (string) to use for all cache keys

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  # always_raise: [],

  # Calculation options
  units: :mi # :km for kilometers or :mi for miles
  # distances: :linear          # :spherical or :linear
)
