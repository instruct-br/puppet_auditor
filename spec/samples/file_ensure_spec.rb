require 'spec_helper'

describe 'fixed_file_ensure' do
  let(:yaml) do
    <<-YAML
    puppet_auditor_version: '1'
    rules:
    - name: Fixed file ensure
      resource: file
      attributes:
        ensure:
          not_matches: file|directory|absent|link
      message: File não pode usar present ou string qualquer
    YAML
  end
  let(:msg) { 'File não pode usar present ou string qualquer' }

  context 'file with ensure file' do
    let (:code) {
      <<-MANIFEST
      file { '/etc/myapp/myapp.conf':
        ensure => file,
      }
      MANIFEST
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'file with ensure present' do
    let (:code) {
      <<-EOS
      file { '/etc/myapp/myapp.conf':
        ensure => present,
      }
      EOS
    }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(2).in_column(19)
    end
  end
end
