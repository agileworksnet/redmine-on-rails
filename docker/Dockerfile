FROM redmine:latest

# Copy dummy script (kept for reference, optional)
# COPY scripts/dummy.rb /usr/src/redmine/scripts/dummy.rb

# Copy the provisioning initializers
# 00-provision_roles.rb runs first (creates Roles)
COPY scripts/roles.rb /usr/src/redmine/config/initializers/00-provision_roles.rb

# 01-provision_issue_statuses.rb runs second (creates Issue Statuses)
COPY scripts/issue_statuses.rb /usr/src/redmine/config/initializers/01-provision_issue_statuses.rb

# 02-provision_trackers.rb runs third (creates Trackers, depends on Statuses)
COPY scripts/trackers.rb /usr/src/redmine/config/initializers/02-provision_trackers.rb

# 10-provision_groups.rb runs second (creates groups)
COPY scripts/groups.rb /usr/src/redmine/config/initializers/10-provision_groups.rb

# 20-provision_users.rb runs third (creates users and assigns groups)
COPY scripts/users.rb /usr/src/redmine/config/initializers/20-provision_users.rb

# 30-provision_projects.rb runs fourth (creates projects, assigns members & trackers)
COPY scripts/projects.rb /usr/src/redmine/config/initializers/30-provision_projects.rb

# 40-provision_workflows.rb runs fifth (defines workflow transitions)
COPY scripts/workflows.rb /usr/src/redmine/config/initializers/40-provision_workflows.rb

# 90-settings_email.rb runs last (configures email/server settings)
COPY scripts/settings/email.rb /usr/src/redmine/config/initializers/90-settings_email.rb

