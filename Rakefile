# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'sqrbl'

task :default => 'spec:run'

PROJ.rubyforge.name = 'sqrbl'
PROJ.name           = 'sqrbl'
PROJ.version        = Sqrbl::VERSION
PROJ.authors        = 'Sam Livingston-Gray'
PROJ.email          = 'geeksam@gmail.com'
PROJ.url            = 'http://sqrbl.rubyforge.org'
PROJ.ignore_file    = '.gitignore'


PROJ.spec.opts << '--color'

# EOF
