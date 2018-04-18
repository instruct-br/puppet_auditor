module PuppetAuditor
  class LintPlugin < PuppetLint::CheckPlugin
    def initialize
      super
      @resource = self.class::RESOURCE
      @attributes = self.class::ATTRIBUTES
      @message = self.class::MESSAGE
    end

    def check
      resource_indexes.each { |resource| resource_block(resource) if resource[:type].value == @resource }
    end

    private

    def resource_block(resource)
      @attributes.each do |attribute_name, comparisson_rules|
        attribute = resource[:tokens].find { |t| t.type == :NAME && t.value == attribute_name && t.next_code_token.type == :FARROW }
        attribute_block(resource, attribute, comparisson_rules) if attribute
      end
    end

    def attribute_block(resource, attribute, comparisson_rules)
      value_token = attribute.next_code_token.next_code_token
      comparisson_rules.each do |rule, value|
        case rule
        when 'matches'
          matches_comparisson(resource, value_token, value)
        when 'equals'
          equals_comparisson(resource, value_token, value)
        end
      end
    end

    def matches_comparisson(resource, token, expected)
      violation(resource, token) if Regexp.new(expected) =~ token.value
    end

    def equals_comparisson(resource, token, expected)
      violation(resource, token) if expected == token.value
    end

    def violation(resource, token)
      notify :warning, {
        message:  @message, 
        line:     token.line, 
        column:   token.column, 
        token:    token, 
        resource: resource
      }
    end
  end
end
