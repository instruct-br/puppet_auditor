
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "puppet_auditor/version"

Gem::Specification.new do |spec|
  spec.name          = "puppet_auditor"
  spec.version       = PuppetAuditor::VERSION
  spec.authors       = ["Oscar Esgalha"]
  spec.email         = ["oscar@instruct.com.br"]
  spec.licenses      = ['MIT']

  spec.summary       = %q{A tool to audit puppet manifests against a set of defined rules}
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = "https://github.com/instruct-br/puppet_auditor"

  # `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^((test|spec|features)/|\..*|Jenkinsfile)}) }
  spec.files          = [
    "Gemfile", "Gemfile.lock", "README.md", "Rakefile", "bin/puppet_auditor",
    "lib/puppet_auditor.rb", "lib/puppet_auditor/cli.rb", "lib/puppet_auditor/error.rb",
    "lib/puppet_auditor/lint_plugin.rb", "lib/puppet_auditor/loader.rb", "lib/puppet_auditor/version.rb",
    "puppet_auditor.gemspec"
  ]
  spec.bindir         = "bin"
  spec.executables    = ["puppet_auditor"]
  spec.require_paths  = ["lib"]

  spec.add_dependency 'puppet-lint', '>= 1.1', '< 3.0'

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency 'rspec-its', '~> 1.0'
  spec.add_development_dependency 'rspec-collection_matchers', '~> 1.0'
  spec.add_development_dependency "simplecov", "~> 0.16"
end
