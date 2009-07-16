module Sqrbl
  class Group
    attr_reader :description

    def initialize(description, &block)
      raise ArgumentError.new("Argument error:  no block given!") unless block_given?
      @description = description
      @block = lambda(&block)
    end
  end
end
