task :default => [:spec]

desc "Run lint check on puppet manifests"
task :lint => :clean do
  require 'puppet-lint'
  linter =  PuppetLint.new
  Dir.glob('./**/*.pp').each do |puppet_file|
    puts "=== Evaluating #{puppet_file}"
    linter.file = puppet_file
    linter.run
    puts
  end
  fail if linter.errors?
end

require 'rspec/core/rake_task'

desc "Run module specs check on puppet manifests"
RSpec::Core::RakeTask.new("spec:modules") do |t|
   t.pattern = './modules/**/*_spec.rb' # don't need this, it's default
   t.verbose = true
   t.rspec_opts = "--format documentation --color"
end

desc "Run full host specs"
RSpec::Core::RakeTask.new("spec:hosts") do |t|
  t.pattern = "spec/**/*_spec.rb"
  t.verbose = true
  t.rspec_opts = "--format documentation --color"
end


task :spec => ["spec:hosts"]
