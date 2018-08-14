require 'spec_helper'

describe 'deny_low_ports' do
  let(:yaml) do
    <<-YAML
    puppet_auditor_version: '1'
    rules:
    - name: Deny low ports
      resource: firewall
      attributes:
        dport:
          less_than: 1024
      message: Should not open port below 1024
    YAML
  end
  let(:msg) { 'Should not open port below 1024' }

  context 'respect class variable scope' do
    let (:code) {
      <<-MANIFEST
      $port = 8080

      class machine_firewall {

        $port = 22

        firewall { 'allow 22 access':
          dport  => $port,
          proto  => tcp,
          action => accept,
        }

      }
      MANIFEST
    }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end
  
    it 'should create a warning' do
      expect(problems).to contain_error(msg).on_line(8).in_column(21)
    end
  end
end
