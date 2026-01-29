Rails.application.config.after_initialize do
  config_file = '/usr/src/redmine/provision/groups.yml'

  if (ActiveRecord::Base.connection.table_exists?('users') rescue false)
    if File.exist?(config_file)
    puts "[PROVISION] Found configuration file: #{config_file}"
    
    begin
      config = YAML.load_file(config_file)
      
      # Provision Groups
      if config['groups']
        puts "[PROVISION] Processing #{config['groups'].count} groups..."
        config['groups'].each do |group_data|
          # Redmine Groups use 'lastname' attribute for the name (inherited from Principal)
          group = Group.find_by_lastname(group_data['name'])
          if group
             puts "[PROVISION] Group '#{group_data['name']}' already exists."
          else
             puts "[PROVISION] Creating group '#{group_data['name']}'..."
             group = Group.new(lastname: group_data['name'])
             if group.save
               puts "[PROVISION] Group '#{group_data['name']}' created."
             else
               puts "[PROVISION] ERROR: Failed to create group '#{group_data['name']}': #{group.errors.full_messages.join(', ')}"
             end
          end
        end
      else
        puts "[PROVISION] No 'groups' key found in configuration file."
      end
    rescue StandardError => e
      puts "[PROVISION] CRITICAL ERROR loading configuration: #{e.message}"
    end
  else
    puts "[PROVISION] No configuration file found at #{config_file}. Skipping groups provisioning."
    end
  end
end
