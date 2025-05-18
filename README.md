# Ansible Laravel 11 Deployment

This Ansible project automates the deployment of all dependencies required to run a Laravel 11 environment.

## Project Structure

```
ansible-laravel/
├── site.yml                # Main playbook
├── README.md               # Project documentation
├── inventory/              # Host inventory
│   └── hosts.yml           # Inventory file
├── group_vars/             # Group variables
│   └── all.yml             # Common variables
├── vars/                   # Global variables
│   └── versions.yml        # Laravel version dependency mapping
└── roles/                  # Ansible roles
    ├── php/                # PHP installation
    ├── composer/           # Composer installation
    ├── nodejs/             # Node.js installation
    ├── mysql/              # MySQL installation
    ├── mariadb/            # MariaDB installation
    ├── postgresql/         # PostgreSQL installation
    ├── redis/              # Redis installation
    └── webserver/          # Web server installation (NGINX/Apache)
```

## Requirements

- Ansible 2.12 or higher
- SSH access to target servers
- Sudo privileges on target servers

## Supported Distributions

- RHEL-like 8 & 9 (AlmaLinux, RockyLinux, OracleLinux)
- Debian-like 11 & 12
- Ubuntu 20.04, 22.04, 24.04

## Variables

The main configuration variables are set in `group_vars/all.yml`:

- `laravel_version`: Laravel version to deploy (default: 11)
- `db_engine`: Database engine to use (options: mysql, mariadb, postgresql)
- `enable_redis`: Whether to install Redis (default: false)
- `webserver_type`: Web server to install (options: nginx, apache)

## Usage

1. Update the inventory file with your server information:
   
   ```yaml
   # inventory/hosts.yml
   all:
     children:
       webservers:
         hosts:
           webserver1:
             ansible_host: 192.168.1.10
   ```

2. Customize the variables in `group_vars/all.yml` if needed.

3. Run the playbook:
   
   ```bash
   ansible-playbook -i inventory/hosts.yml site.yml
   ```

4. To run with specific tags:
   
   ```bash
   ansible-playbook -i inventory/hosts.yml site.yml --tags php,webserver
   ```

## Customizing the Stack

### Database Engine

Set the `db_engine` variable to choose your database:

```yaml
# In group_vars/all.yml or via command line
db_engine: postgresql  # Options: mysql, mariadb, postgresql
```

### Redis

Enable Redis installation:

```yaml
# In group_vars/all.yml or via command line
enable_redis: true
```

### Web Server

Choose between NGINX and Apache:

```yaml
# In group_vars/all.yml or via command line
webserver_type: apache  # Options: nginx, apache
```

## GitHub Actions Workflow Example

Here's a basic GitHub Actions workflow example for CI:

```yaml
name: Ansible Lint

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  ansible-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
          
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install ansible ansible-lint
          
      - name: Lint Ansible Playbook
        run: |
          ansible-lint
```

## License

MIT License

