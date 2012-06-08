task :default => [:test, :parse]

def old_puppet?
  `puppet -V` =~ /^2.[456]/
end

desc "Remove the puppetforce dpkg files"
task :clean do
  Dir["modules/*/pkg"].each do |d|
    puts d
    rm_rf d
  end
end

desc "Run the test suite"
task :test do
  pcommand = old_puppet? ? "puppet" : "puppet apply"
	Dir["manifests/tests/test_*"].each do |test_file|
		sh "#{pcommand} --noop --modulepath modules/ #{test_file}"
	end
end

desc "Parse any .pp files we can find"
task :parse => :clean do
  pcommand = old_puppet? ? "puppet --parseonly --modulepath modules/" : "puppet parser validate --modulepath modules/"

  files = Dir["manifests/**/*.pp", "modules/**/*.pp"]
  if old_puppet?
    files.each { |f| sh "#{pcommand} #{f}" }
  else
    sh "#{pcommand} #{files.join(' ')}"
  end

end

require 'puppet-lint'

desc "Run lint check on puppet manifests"
task :lint => :clean do
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
require 'rspec-puppet'

desc "Run specs check on puppet manifests"
RSpec::Core::RakeTask.new(:spec) do |t|
   t.pattern = './modules/**/*_spec.rb' # don't need this, it's default
   t.verbose = true
   t.rspec_opts = "--format documentation --color"
    # Put spec opts in a file named .rspec in root
end
