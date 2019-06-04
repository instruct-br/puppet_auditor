module PuppetAuditor
  class Cli

    @@path = ''

    def self.path
      @@path
    end

    def initialize(args)
      @checks = []

      host_default = true
      user_default = true
      project_default = true
      specific_yaml_rules = nil

      OptionParser.new do |opts|
        opts.banner = "Usage: puppet_auditor [options]"
      
        opts.on("--with-rules FILE", "Supply more rules from a specific yaml file") do |file|
          specific_yaml_rules = file
        end

        opts.on("--no-host-defaults", "Do not atempt to load yaml rules from /etc/puppet_auditor.yaml") do
          host_default = false
        end

        opts.on("--no-user-defaults", "Do not atempt to load yaml rules from ~/.puppet_auditor.yaml") do
          user_default = false
        end

        opts.on("--no-project-defaults", "Do not atempt to load yaml rules from .puppet_auditor.yaml") do
          project_default = false
        end
      end.parse!

      load_checks('/etc/puppet_auditor.yaml') if host_default
      load_checks('~/.puppet_auditor.yaml')   if user_default && ENV.key?('HOME')
      load_checks('.puppet_auditor.yaml')     if project_default
      load_checks(specific_yaml_rules)        if specific_yaml_rules

      @@path = File.expand_path('.')
    end

    def load_checks(filepath)
      File.open(filepath) { |file| @checks << Loader.new(file).generate_checks } if File.readable?(filepath)
    rescue PuppetAuditor::Error => err
      puts "There was an error parsing rules from #{filepath}"
      puts err.message
      exit 1
    end

    def run!
      PuppetLint::Bin.new([File.expand_path('.'), "--only-checks=#{@checks.join(',')}"]).run
    end
  end
end
