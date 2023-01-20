require "thor"
require "mrsk/sshkit_with_ext"

module Mrsk::Cli
  class Base < Thor
    include SSHKit::DSL

    def self.exit_on_failure?() true end

    class_option :verbose, type: :boolean, aliases: "-v", desc: "Detailed logging"

    class_option :hosts, aliases: "-h", desc: "Run commands on these hosts instead of all (separate by comma)"
    class_option :roles, aliases: "-r", desc: "Run commands on these roles instead of all (separate by comma)"

    class_option :config_file, aliases: "-c", default: "config/deploy.yml", desc: "Path to config file (default: config/deploy.yml)"
    class_option :destination, aliases: "-d", desc: "Specify destination to be used for config file (west -> deploy.west.yml)"

    def initialize(*)
      super
      initialize_commander(options)
    end

    private
      def initialize_commander(options)
        MRSK.tap do |commander|
          commander.config_file = Pathname.new(File.expand_path(options[:config_file]))
          commander.destination = options[:destination]
          commander.hosts       = options[:hosts]&.split(",")
          commander.roles       = options[:roles]&.split(",")
          commander.verbose     = options[:verbose]
        end
      end

      def print_runtime
        started_at = Time.now
        yield
      ensure
        runtime = Time.now - started_at
        puts "  Finished all in #{sprintf("%.1f seconds", runtime)}"
      end
  end
end
