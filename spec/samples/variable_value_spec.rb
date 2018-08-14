require 'spec_helper'

describe 'block_low_ports' do
  let(:yaml) do
    <<-YAML
    puppet_auditor_version: '1'
    rules:
    - name: Block low ports
      resource: firewall
      attributes:
        dport:
          less_than: 1024
      message: Should not open port below 1024
    YAML
  end
  let(:msg) { 'Should not open port below 1024' }

  context 'single variable assignment' do
    let (:code) {
      <<-MANIFEST
      $port = 22

      firewall { 'allow 22 access':
        dport  => $port,
        proto  => tcp,
        action => accept,
      }
      MANIFEST
    }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end
  
    it 'should create a warning' do
      expect(problems).to contain_error(msg).on_line(4).in_column(19)
    end
  end

  context 'variable receives variable' do
    let (:code) {
      <<-MANIFEST
      $number22 = 22

      $port = $number22

      firewall { 'allow 22 access':
        dport  => $port,
        proto  => tcp,
        action => accept,
      }
      MANIFEST
    }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end
  
    it 'should create a warning' do
      expect(problems).to contain_error(msg).on_line(6).in_column(19)
    end
  end
end
