require 'spec_helper'

describe 'no_recurse_on_files' do
  let(:yaml) do
    <<-YAML
    puppet_auditor_version: '1'
    rules:
    - name: No recurse on files
      resource: file
      attributes:
        recurse:
          equals: true
      message: Não usar recurse true em files   
    YAML
  end
  let(:msg) { 'Não usar recurse true em files' }

  context 'file without recurse' do
    let (:code) {
      <<-MANIFEST
      file { '/etc/myapp/keys':
        ensure => directory,
      }
      MANIFEST
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'file with recurse true' do
    let (:code) {
      <<-EOS
      file { '/etc/myapp/keys':
        ensure  => directory,
        recurse => true,
      }
      EOS
    }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_warning(msg).on_line(3).in_column(20)
    end
  end
end
