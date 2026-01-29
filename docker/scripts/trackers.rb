Rails.application.config.after_initialize do
  config_file = '/usr/src/redmine/provision/trackers.yml'

  if (ActiveRecord::Base.connection.table_exists?('trackers') rescue false)
    if File.exist?(config_file)
    puts "[PROVISION] Found configuration file: #{config_file}"
    
    begin
      config = YAML.load_file(config_file)
      
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
      puts "[PROVISION] CRITICAL ERROR loading trackers configuration: #{e.message}"
      puts e.backtrace.join("\n")
    end
  else
    puts "[PROVISION] No configuration file found at #{config_file}. Skipping trackers provisioning."
    end
  end
end
