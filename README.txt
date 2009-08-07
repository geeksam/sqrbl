== SQrbL:  Making database migrations suck less since July 2009!

Copyright (c) 2009 raSANTIAGO + Associates LLC (http://www.rasantiago.com)

The source code for SQrbL can be found on GitHub at:
1. http://github.com/rasantiago/sqrbl/
2. http://github.com/geeksam/sqrbl/

SQrbL's creator and primary author is Sam Livingston-Gray.
    
== DESCRIPTION:

SQrbL was created to help manage an extremely specific problem:  managing SQL-based database migrations.

In essence, SQrbL is a tool for managing multiple SQL queries using Ruby.  SQrbL borrows some terminology and ideas from ActiveRecord's schema migrations, but where ActiveRecord manages changes to your database schema over time, SQrbL was written to manage the process of transforming your data from one schema to another.  (Of course, you could use SQrbL for the former case as well -- just use it to write DDL queries -- but ActiveRecord has better tools for figuring out which migrations have already been applied.)

===How It Works:

You describe the steps in your migration in a SQrbL file.  Each step can produce as much or as little SQL as you like.  Each step has an "up" and a "down" part -- so you can do and undo each step as many times as you need to, until you get it just right.  When you run your SQrbL file, it creates a tree of *.sql files containing the output from your migration steps, one file per step.  It also creates the combined files "all_up.sql" and "all_down.sql"; these contain all of your steps combined into one giant file so that, when Cutover Day arrives, you can copy/paste the whole thing into your SQL client and run it all at once.

===Why It Exists:

SQL is a fantastic DSL for describing queries.  It's not bad at doing transformations, either.  Unfortunately, SQL is, um... rather verbose.  And, it lacks tools for reducing duplication -- if you have to run five similar queries that differ only in their parameters, you have to figure out how to use a prepared statement, but if you have to run five similar queries that differ in the field names they use, that's a bit more work.  SQrbL lets you use SQL for the things SQL is good at, and Ruby for the other stuff.

===About the Name:

SQL.rb seemed a bit too pretentious, so I went with SQrbL -- as in, "You got Ruby in my SQL."  I pronounce it "squirble" (rhymes with "squirrel").  The proper capitalization can be annoying to type, so I've aliased the SQrbL class as Sqrbl.

== SYNOPSIS:

<i>(Note that, in the following code sample, I'm using the convention that do/end blocks are used primarily for their side effects, and curly-brace blocks are used primarily for their return value.)</i>

  Sqrbl.migration "Convert from old widgets to new widgets" do
    set_output_directory '/path/to/generated/sql'

    helpers do
      def widget_import_note
        '"Imported from old_widgets"'
      end
    end

    group "Widgets" do
      step "Create widgets" do
        up do
          action "Migrate old_widgets" {
            <<-SQL
              #{
                insert_into("new_widgets", {
                  :name     => 'widget_name',
                  :part_num => 'CONCAT("X_", part_number)',
                  :note     => widget_import_note,
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

The above code sample describes a migration with one step:  migrating the data in an `old_widgets` table to a `new_widgets` table.  When run, this will generate a set of *.sql files in the directory /path/to/generated/sql.

== REQUIREMENTS:

* Ruby.  (SQrbL was written using MRI Ruby 1.8.6, and has not been tested using other versions.)

== INSTALL:

  sudo gem install rasantiago-sqrbl --source http://gems.github.com

== LICENSE:

SQrbL is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
