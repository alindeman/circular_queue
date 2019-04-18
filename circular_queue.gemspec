$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "circular_queue"
  s.version     = "0.0.5"
  s.authors     = ["Andy Lindeman"]
  s.email       = ["alindeman@gmail.com"]
  s.homepage    = "https://github.com/alindeman/circular_queue"
  s.summary     = "Data structure that uses a single, fixed-size buffer as if it were connected end-to-end"
  s.description = "A circular queue (also called a circular buffer or ring buffer) is useful when buffering data streams"

  s.rubyforge_project = "circular_queue"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rspec", "~>2.11.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "yard"
end
