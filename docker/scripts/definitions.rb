Rails.application.config.after_initialize do
  config_file = '/usr/src/redmine/provision/definitions.yml'

  if File.exist?(config_file)
    puts "[PROVISION] Found configuration file: #{config_file}"
    
    begin
      config = YAML.load_file(config_file)
      
      # 1. Provision Role Definitions
      if config['roles']
        puts "[PROVISION] Processing #{config['roles'].count} roles..."
        config['roles'].each do |role_data|
          role = Role.find_by_name(role_data['name'])
          if role
            puts "[PROVISION] Role '#{role_data['name']}' already exists."
            # Optional: Update permissions if needed? For now, skip.
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

      # 2. Provision Issue Statuses (needed before Trackers can be fully operational usually, but basic create is fine)
      if config['issue_statuses']
        puts "[PROVISION] Processing #{config['issue_statuses'].count} issue statuses..."
        config['issue_statuses'].each do |status_data|
          status = IssueStatus.find_by_name(status_data['name'])
          if status
            puts "[PROVISION] IssueStatus '#{status_data['name']}' already exists."
          else
            puts "[PROVISION] Creating IssueStatus '#{status_data['name']}'..."
            status = IssueStatus.new(name: status_data['name'])
            status.is_closed = status_data['is_closed']
            status.position = status_data['position']
            status.default_done_ratio = status_data['default_done_ratio']
            if status.save
              puts "[PROVISION] IssueStatus '#{status_data['name']}' created."
            else
               puts "[PROVISION] ERROR creating IssueStatus '#{status_data['name']}': #{status.errors.full_messages}"
            end
          end
        end
      end

      # 3. Provision Trackers
      if config['trackers']
        puts "[PROVISION] Processing #{config['trackers'].count} trackers..."
        config['trackers'].each do |tracker_data|
          tracker = Tracker.find_by_name(tracker_data['name'])
          if tracker
            puts "[PROVISION] Tracker '#{tracker_data['name']}' already exists."
          else
            puts "[PROVISION] Creating Tracker '#{tracker_data['name']}'..."
            tracker = Tracker.new(name: tracker_data['name'])
            tracker.position = tracker_data['position']
            tracker.is_in_roadmap = tracker_data['is_in_roadmap']
            
            # Use a default status if available, e.g., the first one we created or "New"
            default_status = IssueStatus.find_by_position(1) || IssueStatus.first
            tracker.default_status = default_status if default_status

            if tracker.save
              puts "[PROVISION] Tracker '#{tracker_data['name']}' created."
            else
              puts "[PROVISION] ERROR creating Tracker '#{tracker_data['name']}': #{tracker.errors.full_messages}"
            end
          end
        end
      end

    rescue StandardError => e
      puts "[PROVISION] CRITICAL ERROR loading definitions configuration: #{e.message}"
      puts e.backtrace.join("\n")
    end
  else
    puts "[PROVISION] No configuration file found at #{config_file}. Skipping definitions provisioning."
  end
end
