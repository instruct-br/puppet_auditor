module PuppetAuditor
  class LintPlugin < PuppetLint::CheckPlugin

    COMPARISONS = {
      'matches'             => ->(expected, token) { token =~ expected },
      'not_matches'         => ->(expected, token) { (token =~ expected).nil? },
      'equals'              => ->(expected, token) { token == expected },
      'not_equal'           => ->(expected, token) { token != expected },
      'less_than'           => ->(expected, token) { token < expected },
      'less_or_equal_to'    => ->(expected, token) { token <= expected },
      'greater_than'        => ->(expected, token) { token > expected },
      'greater_or_equal_to' => ->(expected, token) { token >= expected },
    }

    def initialize
      super
      @resource   = self.class::RESOURCE
      @attributes = self.class::ATTRIBUTES
      @message    = self.class::MESSAGE
    end

    def check
      resource_indexes.each { |resource| resource_block(resource) if resource[:type].value == @resource }
    end

    private

    def resource_block(resource)
      @attributes.each do |attribute_name, comparison_rules|
        attribute = resource[:tokens].find { |t| t.type == :NAME && t.value == attribute_name && t.next_code_token.type == :FARROW }
        attribute_block(resource, attribute, comparison_rules) if attribute
      end
    end

    def attribute_block(resource, attribute, comparison_rules)
      token = attribute.next_code_token.next_code_token
      comparison_rules.each do |rule, value|
        expected, token_value = cast_expected(rule, value), cast_token(token)
        violation(resource, token) if COMPARISONS[rule].call(expected, token_value)
      end
    end

    def cast_expected(rule, expected)
      case rule
      when 'matches', 'not_matches'
        Regexp.new(expected)
      else
        expected
      end
    end

    def cast_token(token)
      case token.type
      when :NUMBER
        token.value.to_i
      when :TRUE
        true
      when :FALSE
        false
      else
        token.value
      end
    end

    def violation(resource, token)
      notify :error, {
        message:  @message, 
        line:     token.line, 
        column:   token.column, 
        token:    token, 
        resource: resource
      }
    end
  end
end
