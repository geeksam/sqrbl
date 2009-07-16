# Swiped from ActiveSupport 2.3.2

unless :to_proc.respond_to?(:to_proc)
  class Symbol
    def to_proc
      Proc.new { |*args| args.shift.__send__(self, *args) }
    end
  end
end
