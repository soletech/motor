# frozen_string_literal: true

$LOAD_PATH.push(File.expand_path("lib", __dir__))

Gem::Specification.new do |s|
  s.name                              = "motor"
  s.author                            = "Recai Oktaş"
  s.email                             = "roktas@gmail.com"
  s.license                           = "GPL-3.0-or-later"
  s.version                           = "0.0.0"
  s.summary                           = "Motor Simplex Solver"
  s.description                       = "Motor Simplex Solver"
  s.homepage                          = "https://motor.roktas.dev"
  s.files                             = Dir["CHANGELOG.md", "LICENSE", "README.md", "lib/**/*"]
  s.executables                       = ["motor", "rotor"]
  s.require_paths                     = ["lib"]
  s.required_ruby_version             = ">= 3.0.0"
  s.metadata["changelog_uri"]         = "https://github.com/soletech/motor/blob/main/CHANGELOG.md"
  s.metadata["source_code_uri"]       = "https://github.com/soletech/motor"
  s.metadata["bug_tracker_uri"]       = "https://github.com/soletech/motor/issues"
  s.metadata["rubygems_mfa_required"] = "true"
end
