require 'spec_helper'

describe 'cant_open_low_ports' do
  let(:yaml) do
    <<-YAML
    puppet_auditor_version: '1'
    rules:
    - name: Cant open low ports
      resource: firewall
      attributes:
        dport:
          less_than: 1024
      message: Não pode abrir portas no firewall abaixo de 1024
    YAML
  end
  let(:msg) { 'Não pode abrir portas no firewall abaixo de 1024' }

  context 'firewall on a high port' do
    let (:code) {
      <<-MANIFEST
      firewall { 'allow 8080 access':
        dport  => 8080,
        proto  => tcp,
        action => accept,
      }
      MANIFEST
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'firewall on a low port' do
    let (:code) {
      <<-MANIFEST
      firewall { 'allow 22 access':
        dport  => 22,
        proto  => tcp,
        action => accept,
      }
      MANIFEST
    }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(2).in_column(19)
    end
  end
end
