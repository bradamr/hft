require_relative 'base'
require_relative '../modules/../modules/restable'

module Ally
  class Account < Base
    include Restable

    CONTEXT = 'accounts'.freeze

    def initialize
      super
    end

    def context
      CONTEXT
    end

    def balances
      api_context = CONTEXT + '/balances'
      api_context = context[1..] if context[0] == '/'
      api_context = with_format(api_context)

      response    = token.get(api_context, CONTENT_TYPE).body
      return JSON.parse(response)
    end
  end
end