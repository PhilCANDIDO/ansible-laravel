# Ansible Laravel 11 Deployment

This Ansible project automates the deployment of all dependencies required to run a Laravel 11 environment. It provides a complete server setup with PHP, Composer, Node.js, database, Redis (optional), and web server configuration.

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
    ├── php/                # PHP installation and configuration
    ├── composer/           # Composer installation
    ├── nodejs/             # Node.js installation
    ├── mysql/              # MySQL installation and configuration
    ├── mariadb/            # MariaDB installation and configuration
    ├── postgresql/         # PostgreSQL installation and configuration
    ├── redis/              # Redis installation (optional)
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
- `webserver_server_name`: Server name for virtual host
- `webserver_laravel_root`: Root directory of Laravel application

### Security Note
For production environments, make sure to change the default passwords in the `group_vars/all.yml` file:

```yaml
mysql_root_password: "secure_password_change_me"
mysql_db_password: "laravel_password_change_me"
mariadb_root_password: "secure_password_change_me"
mariadb_db_password: "laravel_password_change_me"
postgresql_admin_password: "secure_password_change_me"
postgresql_db_password: "laravel_password_change_me"
```

Consider using Ansible Vault to encrypt these sensitive values.

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

You can also pass this as an extra variable when running the playbook:
```bash
ansible-playbook -i inventory/hosts.yml site.yml -e "db_engine=postgresql"
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

### PHP Configuration

Customize PHP settings in `group_vars/all.yml`:

```yaml
php_memory_limit: "256M"
php_post_max_size: "128M"
php_upload_max_filesize: "128M"
php_max_execution_time: 120
```

## Laravel Application Deployment

This playbook sets up the server environment for Laravel but doesn't deploy the application itself. After running the playbook, you'll need to:

1. Clone your Laravel repository to the server
2. Install dependencies with Composer
3. Set up your `.env` file
4. Run migrations and other Laravel setup commands

You can automate this process by extending the playbook with additional tasks.

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

Apache License 2.0