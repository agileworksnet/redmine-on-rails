Rails.application.config.after_initialize do
  config_file = '/usr/src/redmine/provision/projects.yml'

  if (ActiveRecord::Base.connection.table_exists?('projects') rescue false)
    if File.exist?(config_file)
    puts "[PROVISION] Found configuration file: #{config_file}"
    
    begin
      config = YAML.load_file(config_file)
      
      if config['projects']
        puts "[PROVISION] Processing #{config['projects'].count} projects..."
        
        config['projects'].each do |proj_data|
          project = Project.find_by_identifier(proj_data['identifier'])
          
          if project
            puts "[PROVISION] Project '#{proj_data['name']}' (id: #{proj_data['identifier']}) already exists."
          else
            puts "[PROVISION] Creating project '#{proj_data['name']}'..."
            project = Project.new
            project.name = proj_data['name']
            project.identifier = proj_data['identifier']
            project.description = proj_data['description']
            project.is_public = proj_data['is_public'].nil? ? true : proj_data['is_public']
            
            # Explicitly assign All Trackers to the project
            # In Redmine, a project must have trackers enabled to create issues
            project.trackers = Tracker.all

            if project.save
              puts "[PROVISION] Project '#{proj_data['name']}' created with #{project.trackers.count} trackers."
            else
              puts "[PROVISION] ERROR: Failed to create project '#{proj_data['name']}': #{project.errors.full_messages.join(', ')}"
              project = nil
            end
          end

          # Assign Memberships
          if project && proj_data['members']
            proj_data['members'].each do |member_data|
              # Principal can be a User (login) or a Group (lastname)
              principal = User.find_by_login(member_data['principal']) || Group.find_by_lastname(member_data['principal'])
              
              if principal
                # Find roles (by name)
                role_ids = []
                if member_data['roles']
                  member_data['roles'].each do |role_name|
                    # Roles should already exist from definitions.rb
                    role = Role.find_by_name(role_name)
                    if role
                      role_ids << role.id
                    else
                      puts "[PROVISION] WARNING: Role '#{role_name}' not found."
                    end
                  end
                end

                if role_ids.any?
                  # check if membership exists
                  member = Member.find_by(project_id: project.id, user_id: principal.id)
                  unless member
                    puts "[PROVISION] Adding '#{principal.to_s}' to project '#{project.name}' with roles: #{member_data['roles'].join(', ')}..."
                    # Use principal: instead of user: to allow Groups
                    m = Member.new(project: project, principal: principal) 
                    m.role_ids = role_ids
                    if m.save
                       puts "[PROVISION] Membership created."
                    else
                       puts "[PROVISION] ERROR creating membership: #{m.errors.full_messages}"
                    end
                  else
                    # Optional: Update roles if needed, but for simplicity we skip if exists
                    puts "[PROVISION] '#{principal.to_s}' is already a member of '#{project.name}'."
                  end
                end
              else
                puts "[PROVISION] WARNING: Principal '#{member_data['principal']}' not found (User or Group)."
              end
            end
          end
        end
      else
        puts "[PROVISION] No 'projects' key found in configuration file."
      end
    rescue StandardError => e
      puts "[PROVISION] CRITICAL ERROR loading projects configuration: #{e.message}"
    end
  else
    puts "[PROVISION] No configuration file found at #{config_file}. Skipping project provisioning."
    end
  end
end
