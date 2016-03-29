require 'vagrant'

module VagrantPlugins
  module ProviderVirtualBox
    module Action

      class RemountSyncedFolders < SyncedFolders

        def initialize(app, env)
          super(app, env)
        end

        def call(env)
          @env = env
          @app.call(env)

          folders = synced_folders(env[:machine])
          folders.each do |impl_name, fs|
            plugins[impl_name.to_sym][0].new.enable(env[:machine], fs, impl_opts(impl_name, env))
          end
        end
      end

      def self.action_remount_synced_folders
        Vagrant::Action::Builder.new.tap do |b|
          b.use RemountSyncedFolders
        end
      end

    end
  end
end

# Define the plugin.
class RebootPlugin < Vagrant.plugin('2')
  name 'Reboot Plugin'

  provisioner 'reboot' do

    # Create a provisioner.
    class RebootProvisioner < Vagrant.plugin('2', :provisioner)
      # Initialization, define internal state. Nothing needed.
      def initialize(machine, config)
        super(machine, config)
      end

      # Configuration changes to be done. Nothing needed here either.
      def configure(root_config)
        super(root_config)
      end

      # Run the provisioning.
      def provision
        command = 'shutdown -r now'
        @machine.ui.info("Issuing command: #{command}")

        begin
          sleep 5
        end until @machine.communicate.ready?

        # Now the machine is up again, perform the necessary tasks.
        @machine.ui.info("Launching remount_synced_folders action...")
        @machine.action('remount_synced_folders')
      end

      # Nothing needs to be done on cleanup.
      def cleanup
        super
      end
    end
    RebootProvisioner

  end

end