require 'httparty'
require 'oauth'

module Alpaca
  class Base
    include HTTParty

    attr_reader :properties

    PROPERTY_FILES = ['alpaca.yml']

    def initialize
      @properties = Properties.load(PROPERTY_FILES)
    end

    def set_base_uri
      base_uri live? ? properties[:base_uri_live] : properties[:base_uri_paper]
    end

    def live?
      environment == :live
    end

    def environment
      Main::ALPACA_ENV
    end
  end
end
