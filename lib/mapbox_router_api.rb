# frozen_string_literal: true

# https://api.mapbox.com/optimized-trips/v1/mapbox/driving/${stopsList}?access_token=${MAPBOX_PUBLIC_TOKEN}

class MapboxRouterApi
  include HTTParty
  BASE_URL = 'https://api.mapbox.com/optimized-trips/v1/mapbox/driving/'

  API_TOKEN = "?access_token=#{MAPBOX_PUBLIC_TOKEN}"

  def get_route(geocode_list)
    url = "#{BASE_URL}#{geocode_list}#{API_TOKEN}"
    response = HTTParty.get(url)
    case response.code
    when 200
      puts 'NoTrips'
    when 404
      puts 'ProfileNotFound'
    when 405...600
      puts "ZOMG ERROR #{response.code}"
    end
    json = JSON.parse(response.body)
  end
end
