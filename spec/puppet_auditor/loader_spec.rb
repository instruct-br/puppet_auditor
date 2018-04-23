require 'spec_helper'

describe PuppetAuditor::Loader do
  describe "#validate!" do
    context 'yaml without rules key' do
      let(:yaml) do
        <<-YAML
        puppet_auditor_version: '1'
        YAML
      end
      
      it 'should not be valid' do
        @loader = PuppetAuditor::Loader.new(yaml, false)
        expect { @loader.validate! }.to raise_error(PuppetAuditor::Error, 'The rules yaml must have a rules key')
      end
    end

    context 'rule without a name' do
      let(:yaml) do
        <<-YAML
        puppet_auditor_version: '1'
        rules:
        - resource: file
          attributes:
            ensure:
              not_matches: file|directory|absent|link
          message: File não pode usar present ou string qualquer
        YAML
      end

      it 'should not be valid' do
        @loader = PuppetAuditor::Loader.new(yaml, false)
        expect { @loader.validate! }.to raise_error(PuppetAuditor::Error, "All rules must have the 'name' key")
      end
    end

    context 'rule without resource key' do
      let(:yaml) do
        <<-YAML
        puppet_auditor_version: '1'
        rules:
        - name: No bashing allowed
          attributes:
            shell:
              equals: /bin/bash
          message: Cant use shell
        YAML
      end

      it 'should ask for the resource key' do
        @loader = PuppetAuditor::Loader.new(yaml, false)
        msg = "Rule 'No bashing allowed' must have the 'resource' key"
        expect { @loader.validate! }.to raise_error(PuppetAuditor::Error, msg)
      end
    end

    context 'rule without attributes key' do
      let(:yaml) do
        <<-YAML
        puppet_auditor_version: '1'
        rules:
        - name: No bashing allowed
          resource: user
          message: Cant use shell
        YAML
      end

      it 'should ask for the attributes key' do
        @loader = PuppetAuditor::Loader.new(yaml, false)
        msg = "Rule 'No bashing allowed' must have the 'attributes' key"
        expect { @loader.validate! }.to raise_error(PuppetAuditor::Error, msg)
      end
    end

    context 'rule without message key' do
      let(:yaml) do
        <<-YAML
        puppet_auditor_version: '1'
        rules:
        - name: No bashing allowed
          resource: user
          attributes:
            shell:
              equals: /bin/bash
        YAML
      end

      it 'should ask for the message key' do
        @loader = PuppetAuditor::Loader.new(yaml, false)
        msg = "Rule 'No bashing allowed' must have the 'message' key"
        expect { @loader.validate! }.to raise_error(PuppetAuditor::Error, msg)
      end
    end

    context 'rule without message key' do
      let(:yaml) do
        <<-YAML
        puppet_auditor_version: '1'
        rules:
        - name: No bashing allowed
          resource: user
          attributes:
            shell:
              equal: /bin/bash
          message: Cant use shell
        YAML
      end

      it 'should ask for the message key' do
        @loader = PuppetAuditor::Loader.new(yaml, false)
        msg = "Rule 'No bashing allowed' have an invalid comparison: 'equal'"
        expect { @loader.validate! }.to raise_error(PuppetAuditor::Error, msg)
      end
    end
  end
end
