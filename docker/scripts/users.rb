Rails.application.config.after_initialize do
  config_file = '/usr/src/redmine/provision/users.yml'

  if (ActiveRecord::Base.connection.table_exists?('users') rescue false)
    if File.exist?(config_file)
    puts "[PROVISION] Found configuration file: #{config_file}"
    
    begin
      config = YAML.load_file(config_file)
      
      if config['users']
        puts "[PROVISION] Processing #{config['users'].count} users..."
        
        config['users'].each do |user_data|
          # Wrap in a transaction for safety
          User.transaction do
            existing_user = User.find_by_login(user_data['login'])
            user = existing_user
            
            if existing_user
              puts "[PROVISION] User '#{user_data['login']}' already exists. Skipping creation."
            else
              puts "[PROVISION] Creating user '#{user_data['login']}'..."
              user = User.new
              user.login = user_data['login']
              user.password = user_data['password']
              user.password_confirmation = user_data['password']
              user.firstname = user_data['firstname']
              user.lastname = user_data['lastname']
              user.mail = user_data['mail']
              user.admin = user_data['admin'] || false
              user.status = 1 # Active
              user.language = 'en'
              user.auth_source_id = nil
              user.mail_notification = 'only_my_events'
              
              if user.save
                puts "[PROVISION] User '#{user_data['login']}' successfully created."
              else
                puts "[PROVISION] ERROR: Failed to create user '#{user_data['login']}': #{user.errors.full_messages.join(', ')}"
                user = nil # Ensure we don't try to add to group if failed
              end
            end

            # Assign Groups (Groups MUST exist beforehand)
            if user && user_data['groups']
              user_data['groups'].each do |group_name|
                group = Group.find_by_lastname(group_name)
                if group
                  unless user.groups.include?(group)
                    puts "[PROVISION] Adding user '#{user.login}' to group '#{group.lastname}'..."
                    user.groups << group
                  end
                else
                  puts "[PROVISION] WARNING: Group '#{group_name}' not found. Ensure groups provisioning runs first."
                end
              end
            end
          end
        end
      else
        puts "[PROVISION] No 'users' key found in configuration file."
      end
    rescue StandardError => e
      puts "[PROVISION] CRITICAL ERROR loading configuration: #{e.message}"
    end
  else
    puts "[PROVISION] No configuration file found at #{config_file}. Skipping user provisioning."
    end
  end
end
