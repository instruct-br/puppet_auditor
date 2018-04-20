require 'puppet-lint'
require 'puppet_auditor'
PuppetLint::Plugins.load_spec_helper

module RSpec
  module AuditorExampleGroup
    def subject
      rules_loader = PuppetAuditor::Loader.new(yaml)
      rules_loader.generate_checks
      klass = PuppetLint::Checks.new
      filepath = respond_to?(:path) ? path : ''
      klass.load_data(filepath, code)
      check_name = self.class.top_level_description.to_sym
      check = PuppetLint.configuration.check_object[check_name].new
      klass.problems = check.run

      klass.problems = check.fix_problems if PuppetLint.configuration.fix

      klass
    end
  end
end

RSpec.configure do |config|
  config.include(RSpec::LintExampleGroup)
  config.include(RSpec::AuditorExampleGroup)
end
