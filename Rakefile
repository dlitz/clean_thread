require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name = "hospitalportal-cleanthread"
  s.version = "0.0.4"
  s.summary = "Support for threads that exit cleanly"
  s.description = <<EOF
HospitalPortal::CleanThread provides support for developing threads that exit cleanly.

Reliable J2EE deployment requires that all threads started by an application
are able to exit cleanly upon request.
EOF
  s.require_path = "lib"
  s.files = FileList["lib/**/*"].to_a
  s.author = "Infonium Inc."
  s.has_rdoc = true
  s.add_dependency 'hospitalportal-core', '>= 0.0.0'
end

task :gem_install_to_repo => :gem do |t|
  cp "pkg/#{spec.name}-#{spec.version}.gem", "../gem-repo/gems-infonium/"
end

require 'rake/gempackagetask'
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
  pkg.need_zip = true
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rd|
  rd.main = "HospitalPortal::CleanThread"
  rd.rdoc_files.include("lib/**/*.rb")
end
