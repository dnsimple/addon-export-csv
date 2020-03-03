require 'rspec/core/rake_task'

task default: :test
task test: :spec

RSpec::Core::RakeTask.new(:spec) do |task|
  task.rspec_opts = "--color --format progress"
  task.verbose = false
end
