module Ally
  class Base
    attr_reader :properties

    PROPERTY_FILES = %w[ally.yml secrets.yml].freeze

    def initialize
      @properties = Properties.load(PROPERTY_FILES)
    end
  end
end
