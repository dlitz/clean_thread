require 'rubygems'

spec = Gem::Specification.new do |s|
  s.name = "hospitalportal-cleanthread"
  s.version = "0.0.1"
  s.summary = "Support for threads that exit cleanly"
  s.description = "HospitalPortal::CleanThrea provices support for threads that exit cleanly."
  s.require_path = "lib"
  s.files = FileList["lib/**/*"].to_a
  s.author = "Infonium Inc."
  s.has_rdoc = true
end

require 'rake/gempackagetask'
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
  pkg.need_zip = true
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rd|
  rd.rdoc_files.include("lib/**/*.rb")
end
