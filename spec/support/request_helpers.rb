# frozen_string_literal: true

module Requests
  module Jsonhelpers
    def json
      JSON.parse(response.body)
    end
  end
end
