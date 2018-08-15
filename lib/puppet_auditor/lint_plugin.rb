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
      @resource         = self.class::RESOURCE
      @attributes       = self.class::ATTRIBUTES
      @message          = self.class::MESSAGE
      @scoped_variables = { 'global' => {} }
      @scopes           = {}
    end

    def check
      discover_scopes
      scan_variables
      resource_indexes.each { |resource| resource_block(resource) if resource[:type].value == @resource }
    end

    private

    def class_scopes
      class_indexes.each do |class_hash|
        class_name = class_hash[:tokens].first.next_code_token
        if class_name.type == :NAME
          @scopes["class_#{class_name.value}"] = [class_hash[:start], class_hash[:end]]
          @scoped_variables["class_#{class_name.value}"] = {}
        end
      end
    end

    def defined_type_scopes
      defined_type_indexes.each do |defined_type_hash|
        defined_type_name = defined_type_hash[:tokens].first.next_code_token
        if defined_type_name.type == :NAME
          @scopes["dtype_#{defined_type_name.value}"] = [defined_type_hash[:start], defined_type_hash[:end]]
          @scoped_variables["dtype_#{defined_type_name.value}"] = {}
        end
      end
    end

    def node_scopes
      node_indexes.each do |node_hash|
        node_name = node_hash[:tokens].first.next_code_token
        if node_name.type == :SSTRING
          @scopes["node_#{node_name.value}"] = [node_hash[:start], node_hash[:end]]
          @scoped_variables["node_#{node_name.value}"] = {}
        end
      end
    end

    def scope(index)
      @scopes.sort_by { |name, range|
        if name.start_with?('class')
          0
        elsif name.start_with?('dtype')
          1
        elsif name.start_with?('node')
          2
        else
          3
        end
      }.find(-> { ['global'] }) { |name, range| index.between?(*range) }.first
    end

    def token_index(unknown)
      tokens.find_index { |indexed| indexed.line == unknown.line && indexed.column == unknown.column }
    end

    def discover_scopes
      class_scopes
      defined_type_scopes
      node_scopes
    end

    def scan_variables
      # This method works because:
      # - "variable assignments are evaluation-order dependent"
      # - "Unlike most other languages, Puppet only allows a given variable to be assigned once within a given scope"
      #
      # See: https://puppet.com/docs/puppet/5.5/lang_variables.html
      tokens.each_with_index do |token, index|
        if token.type == :VARIABLE && token.next_code_token.type == :EQUALS
          @scoped_variables[scope(index)][token.value] = cast_token(token.next_code_token.next_code_token)
        end
      end
    end

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
      when :DQPRE # String with variables
        full_str = token.value
        next_token = token
        while next_token.type != :DQPOST
          next_token = next_token.next_code_token
          if next_token.type == :VARIABLE
            full_str += cast_token(next_token) || "${#{next_token.value}}"
          else
            full_str += next_token.value
          end
        end
        full_str
      when :VARIABLE
        @scoped_variables[scope(token_index(token))][token.value]
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
