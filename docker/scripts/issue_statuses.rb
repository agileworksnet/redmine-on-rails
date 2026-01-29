Rails.application.config.after_initialize do
  config_file = '/usr/src/redmine/provision/issue_statuses.yml'

  if (ActiveRecord::Base.connection.table_exists?('issue_statuses') rescue false)
    if File.exist?(config_file)
    puts "[PROVISION] Found configuration file: #{config_file}"
    
    begin
      config = YAML.load_file(config_file)
      
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
    rescue StandardError => e
      puts "[PROVISION] CRITICAL ERROR loading issue statuses configuration: #{e.message}"
      puts e.backtrace.join("\n")
    end
  else
    puts "[PROVISION] No configuration file found at #{config_file}. Skipping issue statuses provisioning."
    end
  end
end
