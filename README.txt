== SQrbL:  Making data migrations suck less since July 2009!

    Copyright (c) 2009 raSANTIAGO + Associates LLC
    http://www.rasantiago.com/
    http://github.com/rasantiago/
    
    (SQrbL's primary author is Sam Livingston-Gray.)

== DESCRIPTION:

SQrbL was created to help manage an extremely specific problem:  managing SQL-based database migrations.

In essence, SQrbL is a tool for managing multiple SQL queries using Ruby.  SQrbL borrows some language from ActiveRecord's schema migrations, but where ActiveRecord manages changes to your database schema over time, SQrbL was written to manage the process of transforming your data from one schema to another.  (Of course, if you want to use SQrbL to write your DDL, you could -- but ActiveRecord probably has better tools for that.)

HOW IT WORKS:  You describe the steps in your migration in a SQrbL file.  Each step can produce as much or as little SQL as you like.  Each step has an "up" and a "down" part -- so you can do and undo each step as many times as you need to, until you get it just right.  When you run your SQrbL file, it creates individual files containing the output from your migration steps.  It also creates the combined files "all_up.sql" and "all_down.sql"; these contain all of your steps combined into one giant file so that, when Cutover Day arrives, you can run the whole shebang in one go.

WHY IT EXISTS:  SQL is a fantastic DSL for describing queries.  It's not bad at doing transformations, either.  Unfortunately, SQL is, um... rather verbose.  And, it lacks tools for reducing duplication -- if you have to run five similar queries that differ only in their parameters, you have to figure out how to use a prepared statement, but if you have to run five similar queries that differ in the field names they use, that's a bit more work.  SQrbL lets you use SQL for the things SQL is good at, and Ruby for the things that SQL isn't good at.

== FEATURES/PROBLEMS:

* FIXME (list of features or problems)

== SYNOPSIS:

  Sqrbl.migration "Convert from old widgets to new widgets" do
    group "Widgets" do
      step "Create widgets" do
        up do
          action "Migrate old_widgets" {
            <<-SQL
              #{
                insert_into("new_widgets", {
                  :name     => 'widget_name',
                  :part_num => 'CONCAT("X_", part_number)',
                  :note     => '"Imported from old_widgets"',
                })
              }
              FROM old_widgets
            SQL
          }
        end

        down do
          action "Drop imported organizational contacts" {
            'DELETE FROM new_widgets WHERE note LIKE "Imported from old_widgets"'
          }
        end
      end
    end
  end

== REQUIREMENTS:

* FIXME (list of requirements)

== INSTALL:

* sudo gem install rasantiago-sqrbl --source http://gems.github.com

== LICENSE:

(The MIT License)

Copyright (c) 2009 FIXME (different license?)

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
