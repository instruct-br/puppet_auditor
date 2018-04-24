require 'spec_helper'

describe 'no_rm_inside_exec' do
  let(:yaml) do
    <<-YAML
    puppet_auditor_version: '1'
    rules:
    - name: No rm inside exec
      resource: exec
      attributes:
        command:
          matches: rm\s*-rf
      message: Não pode executar rm -rf em um exec!
    YAML
  end
  let(:msg) { 'Não pode executar rm -rf em um exec!' }

  context 'exec without rm -rf' do
    let (:code) {
      <<-MANIFEST
      exec { 'foo exec':
        command => 'touch bar',
      }
      MANIFEST
    }

    it 'should not detect any problems' do
      expect(problems).to have(0).problems
    end
  end

  context 'exec with rm -rf' do
    let (:code) {
      <<-EOS
      exec { 'foo exec':
        command => 'rm -rf',
      }
      EOS
    }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end

    it 'should create a warning' do
      expect(problems).to contain_error(msg).on_line(2).in_column(20)
    end
  end
end
