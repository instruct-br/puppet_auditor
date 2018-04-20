module PuppetAuditor
  class Loader
    def initialize(yaml_str)
      @spec = YAML.load(yaml_str)
      validate!
    end

    def validate!
      # Validate the yaml
    end

    def generate_checks
      @spec['rules'].map do |rule|
        rule_name = rule['name'].downcase.gsub(/[^a-z0-9\-_]+/i, '_')
        rule_sym = rule_name.to_sym
        class_name = rule_sym.to_s.split('_').map(&:capitalize).join
        klass = PuppetLint.const_set("Check#{class_name}", Class.new(PuppetAuditor::LintPlugin))
        klass.const_set('NAME', rule_sym)
        klass.const_set('RESOURCE', rule['resource'])
        klass.const_set('ATTRIBUTES', rule['attributes'])
        klass.const_set('MESSAGE', rule['message'])
        PuppetLint.configuration.add_check(rule_sym, klass)
        PuppetLint::Data.ignore_overrides[rule_sym] ||= {}
        rule_name
      end
    end
  end
end
