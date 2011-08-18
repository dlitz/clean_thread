# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "clean_thread/version"

Gem::Specification.new do |s|
  s.name        = "clean_thread"
  s.version     = CleanThread::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Dwayne Litzenberger"]
  s.email       = ["dlitz@patientway.com"]
  s.homepage    = "https://github.com/dlitz/clean_thread"
  s.summary     = %q{Support for threads that exit cleanly}
  s.description = <<EOF
CleanThread provides support for developing threads that exit cleanly.

Reliable J2EE deployment requires that all threads started by an application
are able to exit cleanly upon request.
EOF

  s.rubyforge_project = "clean_thread"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
