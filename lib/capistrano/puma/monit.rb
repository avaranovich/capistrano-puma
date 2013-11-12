# Puma - Monit
# Setup and management of Monit for Puma
#
require 'capistrano/puma/config'
require 'capistrano/base_helper/monit_base'

Capistrano::Configuration.instance(true).load do
  after "monit:setup", "puma:monit:setup"
  after "puma:monit:setup", "puma:monit:enable"
  after "puma:monit:enable", "monit:reload"

  before "puma:monit.disable", "puma:monit:unmonitor"
  after  "puma:monit:disable", "monit:reload"

  # start service after update in case it has not been stopped
  # after "deploy:update", "puma:monit:start"
  # Not needed?

  namespace :puma do
    namespace :monit do
      desc "Setup Puma monit-service"
      task :setup do
       on roles :app do
        # Upload configuration
        Capistrano::BaseHelper::generate_and_upload_config(puma_local_monit_config, File.join(fetch(:monit_available_path), "#{fetch(:puma_runit_service_name)}.conf"))
        # Enable monitor
       end
      end
    
      desc "Enable monit services for Puma"
      task :enable
       on roles :app do
        Capistrano::MonitBase::Service.enable("#{fetch(:puma_runit_service_name)}.conf")
       end
      end

      desc "Disable and stop monit services for Puma"
      task :disable
       on roles :app do
        Capistrano::MonitBase::Service.disable("#{fetch(:puma_runit_service_name)}.conf")
       end 
      end

      desc "Start monit services for Puma (will also try to start the service)"
      task :start do
       on roles :app do 
        Capistrano::MonitBase::Service.command_monit("start", fetch(:puma_monit_service_name))
       end 
      end

      desc "Stop monit services for Puma (will also stop the service)"
      task :stop do
       on roles :app do 
        Capistrano::MonitBase::Service.command_monit("stop", fetch(:puma_monit_service_name))
       end 
      end

      desc "Restart monit services for Puma"
      task :restart do
       on roles :app do 
        Capistrano::MonitBase::Service.command_monit("restart", fetch(:puma_monit_service_name))
       end 
      end

      desc "Monitor Puma"
      task :monitor do
       on roles :app do 
        Capistrano::MonitBase::Service.command_monit("monitor", fetch(:puma_monit_service_name))
       end 
      end

      desc "Unmonitor Puma"
      task :unmonitor do
       on roles :app do 
        Capistrano::MonitBase::Service.command_monit("unmonitor", fetch(:puma_monit_service_name))
       end 
      end

      desc "Purge Puma monit configuration"
       task :unmonitor :on_error => :continue do
      end      
    end

  end
end