require 'optparse'

module VagrantPlugins
  module CloudCommand
    module AuthCommand
      module Command
        class Logout < Vagrant.plugin("2", :command)
          def execute
            options = {}

            opts = OptionParser.new do |o|
              o.banner = "Usage: vagrant cloud auth logout [options]"
              o.separator ""
              o.separator "Logs you out if you're logged in locally."
              o.separator ""
              o.separator "Options:"
              o.separator ""
              o.on("-u", "--username USERNAME_OR_EMAIL", String, "Specify your Vagrant Cloud username or email address") do |l|
                options[:login] = l
              end
            end

            # Parse the options
            argv = parse_options(opts)
            return if !argv
            if argv.length > 1
              raise Vagrant::Errors::CLIInvalidUsage,
                help: opts.help.chomp
            end

            # Initializes client and deletes token on disk
            @client = VagrantPlugins::CloudCommand::Util.client_login(@env, options[:username])

            @client.clear_token
            @env.ui.success(I18n.t("cloud_command.logged_out"))
            return 0
          end
        end
      end
    end
  end
end
