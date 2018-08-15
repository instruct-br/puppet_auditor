require 'spec_helper'

describe 'cant_edit_sudoers' do
  let(:yaml) do
    <<-YAML
    puppet_auditor_version: '1'
    rules:
    - name: Cant edit sudoers
      resource: file_line
      attributes:
        path:
          equals: /etc/sudoers
      message: Do not edit /etc/sudoers!
    YAML
  end
  let(:msg) { 'Do not edit /etc/sudoers!' }

  context 'attempt to sneak sudoers' do
    let (:code) {
      <<-MANIFEST
      $haha = 'sudoers'

      file_line { 'sudo_rule_nopw':
        path => "/etc/${haha}",
        line => '%sudonopw ALL=(ALL) NOPASSWD: ALL',
      }
      MANIFEST
    }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_error(msg).on_line(4).in_column(17)
    end
  end

  context 'attempt to sudoers' do
    let (:code) {
      <<-MANIFEST
      $s = 's'
      $u = 'u'
      $d = 'd'
      $o = 'o'
      $e = 'e'
      $r = 'r'

      file_line { 'sudo_rule_nopw':
        path => "/etc/${s}${u}${d}${o}${e}${r}${s}",
        line => '%sudonopw ALL=(ALL) NOPASSWD: ALL',
      }
      MANIFEST
    }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_error(msg).on_line(9).in_column(17)
    end
  end

  context 'unknown variable' do
    let (:code) {
      <<-MANIFEST
      $woooo = 1
      file_line { 'module_config':
        path => "/etc/${sudoers}",
        line => 'foofoofoo',
      }
      MANIFEST
    }

    it 'should not detect a problem' do
      expect(problems).to have(0).problem
    end
  end
end


