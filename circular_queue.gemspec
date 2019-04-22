lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |s|
  s.name        = "circular_queue"
  s.version     = "1.0.1"
  s.authors     = ["Andy Lindeman"]
  s.email       = ["alindeman@gmail.com"]

  s.summary     = "Data structure that uses a single, fixed-size buffer as if it were connected end-to-end"
  s.homepage    = "https://github.com/alindeman/circular_queue"
  s.description = "A circular queue (also called a circular buffer or ring buffer) is useful when buffering data streams"
  s.license     = "MIT"
  s.metadata    = {
    "homepage_uri" => "https://github.com/alindeman/circular_queue",
    "changelog_uri" => "https://github.com/alindeman/circular_queue/blob/master/CHANGELOG.md",
    "source_code_uri" => "https://github.com/alindeman/circular_queue",
  }

  s.rubyforge_project = "circular_queue"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "bundler", "~> 2.0"
  s.add_development_dependency "pry-byebug"
  s.add_development_dependency "rspec", "~> 3.8.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "yard"
end
