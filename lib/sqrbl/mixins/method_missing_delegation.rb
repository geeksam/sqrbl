# This file is part of SQrbL, which is free software licensed under v3 of the GNU GPL.
# For more information, please see README.txt and LICENSE.txt in the project's root directory.


module Sqrbl
  # When used as directed, Sqrbl will create a graph of objects with bidirectional
  # references to one another.  The graph will have the following general shape
  # (where --> indicates a relationship that is generally one-to-many):
  #
  # Migration --> Group --> StepPair --> Step
  #
  # Also, because these various objects are created with blocks that are
  # instance_eval'd, those blocks can define helper methods that will be
  # added to the appropriate objects in the graph.
  #
  # Taken together, these two features (back-references and instance_eval)
  # let us provide a useful facility for defining helper methods inside a
  # block, and accessing them using scoping rules that work in an intuitive
  # manner.  For example, if a Migration defines a method #foo, which is
  # later called from inside a Step's block, the Step can catch that call
  # using method_missing and delegate it to its StepPair, which in turn
  # will delegate to its Group, which in turn will delegate to its Migration.
  #
  # Confused yet?  Here's a slightly modified version of the example in README.txt:
  #
  #   Sqrbl.migration "Convert from old widgets to new widgets" do
  #     def new_widget_insert()
  #       insert_into("new_widgets", {
  #         :name     => 'widget_name',
  #         :part_num => 'CONCAT("X_", part_number)',
  #         :note     => '"Imported from old_widgets"',
  #       })
  #     end
  #
  #     group "Widgets" do
  #       step "Create widgets" do
  #         up do
  #           action "Migrate old_widgets" {
  #             "#{new_widget_insert()} FROM old_widgets"
  #           }
  #         end
  #
  #         down do
  #           action "Drop imported organizational contacts" {
  #             'DELETE FROM new_widgets WHERE note LIKE "Imported from old_widgets"'
  #           }
  #         end
  #       end
  #     end
  #   end
  #
  # Note that the call to new_widget_insert occurs several layers of
  # nesting down from its definition.  By using this method_missing
  # delegation strategy, we can effectively hide Sqrbl's object model
  # from the user and provide something that "just works."
  #
  # (Without this strategy, the above example would need to define
  # new_widget_insert as a lambda function that gets invoked using
  # either #call or the square-bracket syntax, but I find that more
  # awkward -- hence this wee bit of metaprogramming.)
  module MethodMissingDelegation
    def self.included(receiver)
      receiver.class_eval(<<-EOF, __FILE__, __LINE__)
        @@mm_delegate_accessor = nil

        # Defines the accessor method that instances of this class should use
        # when delegating +method_missing+ calls.
        def self.delegate_method_missing_to(accessor)
          @@mm_delegate_accessor = accessor
        end

        # If +delegate_method_missing_to+ was called on the class,
        # use the accessor defined there to find a delegate and
        # pass the unknown method to it.
        def method_missing(method, *args, &block)
          return super unless defined?(@@mm_delegate_accessor) && !@@mm_delegate_accessor.nil?
          delegate = self.send(@@mm_delegate_accessor)
          delegate.send(method, *args, &block)
        end
      EOF
    end
  end
end
