# Redmine-on-Rails

![Redmine](https://img.shields.io/badge/Redmine-5.0+-b52024?style=for-the-badge&logo=redmine&logoColor=white)
![Rails](https://img.shields.io/badge/Rails-7.0+-CC0000?style=for-the-badge&logo=rubyonrails&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-20.10+-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![Ruby](https://img.shields.io/badge/Ruby-3.0+-CC342D?style=for-the-badge&logo=ruby&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)

Redmine-on-Rails is a containerized Redmine solution designed to simplify configuration management through a "Provisioning as Code" approach. By leveraging standard Ruby on Rails initializers, it automatically configures your Redmine instance every time it starts, ensuring consistency and saving you from repetitive manual setup.

## Features

*   **Provisioning as Code**: Manage your Roles, Trackers, Statuses, Groups, Users, Projects, Workflows, and Settings using simple, readable YAML files.
*   **Zero-Config Startup**: Launch a fully configured Redmine instance with a single command, ready for use immediately.
*   **Smart Execution**: Provisioning scripts run automatically on boot but remain intelligent enough to apply changes only when needed, effectively preventing duplicates.
*   **Migration Safe**: Built-in safeguards ensure that provisioning waits for database migrations to complete, guaranteeing a smooth and error-free startup process.
*   **Dockerized**: Runs in a fully isolated environment using Docker and Docker Compose.

## Quick Start

1.  **Clone the repository**:

```bash
git clone https://github.com/yourusername/redmine-on-rails.git
cd redmine-on-rails
```

2.  **Start the application**:

```bash
docker compose up -d --build
```

3.  **Access Redmine**:

Open your browser and navigate to `http://localhost:8080`.

*   **User**: `admin` / `admin` (default)
*   **Provisioned User**: `manager` / `password123` (defaults to 12345678 if configured)

## Configuration

The provisioning system watches the `provision/` directory. Modify these YAML files to customize your setup:

* `provision/settings/email.yml`: Server and email configuration.
* `provision/roles.yml`: Define user roles.
* `provision/trackers.yml`: Define issue trackers.
* `provision/issue_statuses.yml`: Define issue statuses.
* `provision/workflows.yml`: Define workflow transitions.
* `provision/groups.yml`: Create user groups.
* `provision/users.yml`: Create users and assign groups.
* `provision/projects.yml`: Create projects and assign members.

## License

This project is open-source and available under the [MIT License](LICENSE).
