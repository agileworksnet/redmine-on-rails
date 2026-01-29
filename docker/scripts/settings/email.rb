Rails.application.config.after_initialize do
  config_file = '/usr/src/redmine/provision/settings/email.yml'

  # Guard against running during db:migrate when tables don't exist yet
  # Using 'settings' table check
  if (ActiveRecord::Base.connection.table_exists?('settings') rescue false)
    if File.exist?(config_file)
      puts "[PROVISION] Found configuration file: #{config_file}"
      
      begin
        config = YAML.load_file(config_file)
        
        if config['settings']
          puts "[PROVISION] Processing email/server settings..."
          
          config['settings'].each do |key, value|
            # Check if setting value is different to avoid unnecessary writes
            if Setting[key] != value
              puts "[PROVISION] Updating Setting['#{key}'] to '#{value}'..."
              Setting[key] = value
            else
              puts "[PROVISION] Setting['#{key}'] is already '#{value}'."
            end
          end
          
          puts "[PROVISION] Email/Server settings updated."
        end

      rescue StandardError => e
        puts "[PROVISION] CRITICAL ERROR loading settings configuration: #{e.message}"
        puts e.backtrace.join("\n")
      end
    else
      puts "[PROVISION] No configuration file found at #{config_file}. Skipping settings provisioning."
    end
  end
end
