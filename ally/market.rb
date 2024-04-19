require_relative 'base'
require_relative '../modules/../modules/restable'

module Ally
  class Market < Base
    include Restable

    CONTEXT = 'market'.freeze

    def initialize
      super
    end

    def context
      CONTEXT
    end

    def clock
      api_context = CONTEXT + '/clock'
      api_context = context[1..] if context[0] == '/'
      api_context = with_format(api_context)

      response    = token.get(api_context, CONTENT_TYPE).body
      return JSON.parse(response)
    end
  end
end