require 'json'
require 'oauth'

module Restable
  attr_reader :properties

  CONTENT_TYPE = { 'Content-Type': 'application/json' }.freeze

  def context
    raise 'Implement me'
  end

  def all
    find
  end

  def find(id = nil)
    return if context.nil? || context.empty?

    api_context = context
    api_context = context[1..] if context[0] == '/'

    begin
      api_context = with_format(api_context, id)
      response    = token.get(api_context, CONTENT_TYPE).body
      return JSON.parse(response)
    rescue StandardError => e
      puts "Error getting resource: #{api_context}, errors: #{e.message}"
    end
  end

  def token
    consumer = OAuth::Consumer.new(properties[:consumer_key], 'def', { site: properties[:base_uri] })
    OAuth::AccessToken.new(consumer, properties[:oauth_token], properties[:oauth_token_secret])
  end

  def with_format(api_context, id = nil)
    id = "/#{id}" unless id.nil?
    "/#{api_context}#{id}.json"
  end
end