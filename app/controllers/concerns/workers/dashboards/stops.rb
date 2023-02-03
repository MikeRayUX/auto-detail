# frozen_string_literal: true

module Workers::Dashboards::Stops
  protected

  # def get_stops_list
  #   @geocode_list = []
  #   @starting_point = "#{@worker.address.longitude},#{@worker.address.latitude}"

  #   @geocode_list.push(@starting_point)
  #   @accepted_offers.each do |n|
  #     @geocode_list.push("#{n.longitude},#{n.latitude}")
  #   end
  #   @geocode_list = @geocode_list.join(';')
  #   @api = MapboxRouterApi.new
  #   @response = @api.get_route(@geocode_list)['waypoints']
  #   @waypoint_index = []
  #   @response.each do |n|
  #     @waypoint_index.push(n['waypoint_index'])
  #   end
  # end
end
