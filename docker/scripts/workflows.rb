Rails.application.config.after_initialize do
  config_file = '/usr/src/redmine/provision/workflows.yml'

  if (ActiveRecord::Base.connection.table_exists?('workflows') rescue false)
    if File.exist?(config_file)
    puts "[PROVISION] Found configuration file: #{config_file}"
    
    begin
      config = YAML.load_file(config_file)
      
      if config['workflows']
        puts "[PROVISION] Processing #{config['workflows'].count} workflow definitions..."
        
        config['workflows'].each do |workflow_data|
          role_name = workflow_data['role']
          tracker_name = workflow_data['tracker']
          
          role = Role.find_by_name(role_name)
          tracker = Tracker.find_by_name(tracker_name)
          
          unless role
            puts "[PROVISION] WARNING: Role '#{role_name}' not found. Skipping workflow."
            next
          end
          
          unless tracker
            puts "[PROVISION] WARNING: Tracker '#{tracker_name}' not found. Skipping workflow."
            next
          end
          
          puts "[PROVISION] Setting workflows for Role '#{role_name}' on Tracker '#{tracker_name}'..."
          
          if workflow_data['transitions']
            workflow_data['transitions'].each do |transition|
              status_from_name = transition['from']
              status_from = IssueStatus.find_by_name(status_from_name)
              
              unless status_from
                puts "[PROVISION] WARNING: From-Status '#{status_from_name}' not found. Skipping."
                next
              end
              
              targets = transition['to']
              targets = [targets] unless targets.is_a?(Array)
              
              targets.each do |status_to_name|
                status_to = IssueStatus.find_by_name(status_to_name)
                
                unless status_to
                  puts "[PROVISION] WARNING: To-Status '#{status_to_name}' not found. Skipping."
                  next
                end
                
                # Check if transition exists
                exists = WorkflowTransition.where(
                  role_id: role.id,
                  tracker_id: tracker.id,
                  old_status_id: status_from.id,
                  new_status_id: status_to.id
                ).exists?
                
                unless exists
                  w = WorkflowTransition.new
                  w.role = role
                  w.tracker = tracker
                  w.old_status = status_from
                  w.new_status = status_to
                  if w.save
                    # puts "[PROVISION] Created transition: #{status_from.name} -> #{status_to.name}"
                  else
                     puts "[PROVISION] ERROR creating transition #{status_from.name} -> #{status_to.name}: #{w.errors.full_messages}"
                  end
                end
              end
            end
            puts "[PROVISION] Workflows updated for #{role.name}/#{tracker.name}."
          end
        end
      else
        puts "[PROVISION] No 'workflows' key found in configuration file."
      end
    rescue StandardError => e
      puts "[PROVISION] CRITICAL ERROR loading workflows configuration: #{e.message}"
      puts e.backtrace.join("\n")
    end
  else
    puts "[PROVISION] No configuration file found at #{config_file}. Skipping workflow provisioning."
    end
  end
end
