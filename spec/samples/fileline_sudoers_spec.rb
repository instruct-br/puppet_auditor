require 'spec_helper'

describe 'no_sudoers_fileline' do
  let(:yaml) do
    <<-YAML
    puppet_auditor_version: '1'
    rules:
    - name: No sudoers fileline
      resource: file_line
      attributes:
        path:
          equals: /etc/sudoers
      message: Não pode alterar linhas do /etc/sudoers!
    YAML
  end
  let(:msg) { 'Não pode alterar linhas do /etc/sudoers!' }

  context 'file_line a common file' do
    let (:code) {
      <<-MANIFEST
      file_line { 'good day motd':
        path => '/etc/motd',
        line => 'Have a great day!',
      }
      MANIFEST
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'file_line /etc/sudoers' do
    let (:code) {
      <<-MANIFEST
      file_line { 'sudo_rule_nopw':
        path => '/etc/sudoers',
        line => '%sudonopw ALL=(ALL) NOPASSWD: ALL',
      }
      MANIFEST
    }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_error(msg).on_line(2).in_column(17)
    end
  end
end


