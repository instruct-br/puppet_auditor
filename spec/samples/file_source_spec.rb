require 'spec_helper'

describe 'no_sudoers_on_source' do
  let(:yaml) do
    <<-YAML
    puppet_auditor_version: '1'
    rules:
    - name: No sudoers on source
      resource: file
      attributes:
        source:
          matches: sudoers
      message: Cant use sudoers on source!
    YAML
  end
  let(:msg) { 'Cant use sudoers on source!' }

  context 'source without sudoers' do
    let (:code) {
      <<-MANIFEST
      file { '/etc/motd':
        source => "puppet://modules/${foo}/motd/",
      }
      MANIFEST
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'exec with rm -rf' do
    let (:code) {
      <<-MANIFEST
      file { '/etc/sudoers':
        source => "puppet://modules/${foo}/sudoers",
      }
      MANIFEST
    }


    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create an error' do
      expect(problems).to contain_error(msg).on_line(2).in_column(19)
    end
  end
end
