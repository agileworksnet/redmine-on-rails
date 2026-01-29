Rails.application.config.after_initialize do
  config_file = '/usr/src/redmine/provision/roles.yml'
  
  # Guard against running during db:migrate when tables don't exist yet
  if (ActiveRecord::Base.connection.table_exists?('roles') rescue false)
    if File.exist?(config_file)
      puts "[PROVISION] Found configuration file: #{config_file}"
      
      begin
        config = YAML.load_file(config_file)
        
        if config['roles']
          puts "[PROVISION] Processing #{config['roles'].count} roles..."
          config['roles'].each do |role_data|
            role = Role.find_by_name(role_data['name'])
            if role
              puts "[PROVISION] Role '#{role_data['name']}' already exists."
            else
              puts "[PROVISION] Creating Role '#{role_data['name']}'..."
              role = Role.new(name: role_data['name'])
              role.position = role_data['position']
              role.permissions = role_data['permissions']
              if role.save
                puts "[PROVISION] Role '#{role_data['name']}' created."
              else
                puts "[PROVISION] ERROR creating Role '#{role_data['name']}': #{role.errors.full_messages}"
              end
            end
          end
        end
      rescue StandardError => e
        puts "[PROVISION] CRITICAL ERROR loading roles configuration: #{e.message}"
        puts e.backtrace.join("\n")
      end
    else
      puts "[PROVISION] No configuration file found at #{config_file}. Skipping roles provisioning."
    end
  end
end
