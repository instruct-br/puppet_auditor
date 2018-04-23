module PuppetAuditor
  class Loader

    REQUIRED_KEYS     = ['resource', 'attributes', 'message']
    VALID_COMPARISONS = LintPlugin::COMPARISONS.keys()

    MUST_HAVE_RULES     = "The rules yaml must have a rules key"
    MUST_HAVE_NAME      = "All rules must have the 'name' key"
    RULE_WITHOUT_KEY    = ->(name, key) { "Rule '#{name}' must have the '#{key}' key" }
    INVALID_COMPARISON  = ->(name, key) { "Rule '#{name}' have an invalid comparison: '#{key}'" }


    def initialize(yaml_str, validate=true)
      @spec = YAML.load(yaml_str)
      validate! if validate
    end

    def validate!
      raise Error.new(MUST_HAVE_RULES) unless @spec.include?('rules')
      @spec['rules'].each do |rule|
        raise Error.new(MUST_HAVE_NAME) unless rule.include?('name')
        name = rule['name']
        REQUIRED_KEYS.each { |key| raise Error.new(RULE_WITHOUT_KEY.call(name, key)) unless rule.include?(key) }
        rule['attributes'].each do |attribute, comparisons|
          comparisons.keys.each { |key| raise Error.new(INVALID_COMPARISON.call(name, key)) unless VALID_COMPARISONS.include?(key) }
        end
      end
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
