require 'spec_helper'

describe 'check_gerenciamento' do
  let(:yaml) do
    <<-YAML
    puppet_auditor_version: '1'
    rules:
    - name: Check Gerenciamento
      resource: file
      attributes:
        content:
          equals: GTSL
      message: GTSL is not a valid value for gerenciamento anymore
    YAML
  end
  let(:msg) { 'GTSL is not a valid value for gerenciamento anymore' }

  context 'respect scoped variables (before)' do
    let (:code) {
      <<-MANIFEST
      $gerenciamento = 'GT'

      node 'acme.dev' {
      
        $gerenciamento = 'GTS'
      
        class gerenciamento {
      
          $gerenciamento = "GTSL"
          
          file { '/etc/facts.d/gerenciamento.txt':
            ensure => file,
            content => $gerenciamento,
          }
        }
      }
      MANIFEST
    }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end
  
    it 'should create a warning' do
      expect(problems).to contain_error(msg).on_line(13).in_column(24)
    end
  end

  context 'respect scoped variables (after)' do
    let (:code) {
      <<-MANIFEST
      node 'acme.dev' {  
        class gerenciamento {
          $gerenciamento = "GTSL"
          
          file { '/etc/facts.d/gerenciamento.txt':
            ensure => file,
            content => $gerenciamento,
          }
        }
        $gerenciamento = 'GTS'
      }
      $gerenciamento = 'GT'
      MANIFEST
    }

    it 'should detect a single problem' do
      expect(problems).to have(1).problem
    end
  
    it 'should create a warning' do
      expect(problems).to contain_error(msg).on_line(7).in_column(24)
    end
  end
end
