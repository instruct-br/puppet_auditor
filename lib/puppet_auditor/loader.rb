require 'yaml'

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
      for rule in @spec['rules']
        parameterized_name = rule['name'].downcase.gsub(/[^a-z0-9\-_]+/i, '_')
        PuppetLint.new_check(parameterized_name.to_sym) do
          define_method(:check) do
            resource_indexes.each do |resource|
              if resource[:type].value == rule['resource']
                for attribute_name, comparisson_rules in rule['attributes']
                  attribute = resource[:tokens].find { |t| t.type == :NAME && t.value == attribute_name && t.next_code_token.type == :FARROW }
                  if attribute
                    val_token = attribute.next_code_token.next_code_token
                    for comparisson_rule, comparisson_value in comparisson_rules
                      case comparisson_rule
                      when "matches"
                        if Regexp.new(comparisson_value) =~ val_token.value
                          notify :warning, {
                            :message  => rule['message'],
                            :line     => val_token.line,
                            :column   => val_token.column,
                            :token    => val_token,
                            :resource => resource,
                          }
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
