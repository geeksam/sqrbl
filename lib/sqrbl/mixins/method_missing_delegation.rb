# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl
  module MethodMissingDelegation
    def self.included(receiver)
      receiver.class_eval(<<-EOF, __FILE__, __LINE__)
        @@mm_delegate_accessor = nil

        def self.delegate_method_missing_to(accessor)
          @@mm_delegate_accessor = accessor
        end

        def method_missing(method, *args, &block)
          return super unless defined?(@@mm_delegate_accessor) && !@@mm_delegate_accessor.nil?
          delegate = self.send(@@mm_delegate_accessor)
          delegate.send(method, *args, &block)
        end
      EOF
    end
  end
end