# Ansible Laravel 11 Deployment

This Ansible project automates the deployment of all dependencies required to run a Laravel 11 environment with support for application-specific configurations. It provides a complete server setup with PHP, Composer, Node.js, database, Redis (optional), and web server configuration.

## 🆕 Application-Specific Variables Support

**New Feature**: Deploy multiple Laravel applications with individual configurations using application-specific variable files.

```bash
# Setup environment for specific application
ansible-playbook -i inventory/hosts.yml site.yml -e "app_name=neodatabase"

# Deploy the application
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "app_name=neodatabase"
```

## Project Structure

```
ansible-laravel/
├── site.yml                # Main playbook
├── deploy-laravel.yml      # Laravel application deployment
├── laravel-maintenance.yml # Laravel maintenance tasks
├── security-hardening.yml  # Security hardening
├── quick-install.yml       # Quick setup for development
├── README.md               # Project documentation
├── inventory/              # Host inventory
│   └── hosts_sample.yml    # Sample inventory file
├── group_vars/             # Group variables
│   └── all.yml             # Common variables
├── vars/                   # Application-specific variables
│   ├── versions.yml        # Laravel version dependency mapping
│   ├── example-app.yml     # Template for new applications
│   └── neodatabase.yml     # Example application configuration
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

## Laravel 11 Requirements (Automatically Configured)

Based on [Laravel 11 official documentation](https://laravel.com/docs/11.x/deployment), this playbook installs:

- **PHP >= 8.2** with required extensions:
  - Ctype, cURL, DOM, Fileinfo, Filter, Hash, Mbstring
  - OpenSSL, PCRE, PDO, Session, Tokenizer, XML
  - Additional: BCMath, GD, Intl, OPcache, Zip, SQLite3
- **Composer 2.2+** for dependency management
- **Node.js 20.x LTS** for asset compilation
- **Database**: MySQL 8.0+, MariaDB 10.11+, or PostgreSQL 15+
- **Redis 7.0+** (optional) for caching and sessions
- **Web Server**: Nginx 1.24+ or Apache 2.4+

## Quick Start

### 1. Create Application Variables

Copy the template and customize for your application:

```bash
cp vars/example-app.yml vars/myapp.yml
```

Edit `vars/myapp.yml` with your application settings:

```yaml
---
app_name: "myapp"
webserver_server_name: "myapp.example.com"
webserver_laravel_root: "/var/www/myapp"
app_repo_url: "https://github.com/user/myapp.git"
app_repo_branch: "main"

# Database configuration
db_engine: "mysql"
mysql_db_name: "myapp"
mysql_db_user: "myapp_user"
mysql_db_password: "secure_password!"
mysql_root_password: "root_password!"

# ... other configurations
```

### 2. Configure Inventory

Update your inventory file:

```yaml
# inventory/hosts.yml
all:
  children:
    webservers:
      hosts:
        server1:
          ansible_host: 192.168.1.10
          ansible_user: ubuntu
```

### 3. Deploy Environment and Application

```bash
# Setup the Laravel environment
ansible-playbook -i inventory/hosts.yml site.yml -e "app_name=myapp"

# Deploy the application
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "app_name=myapp"
```

## Usage Modes

### Mode 1: Application-Specific Deployment (Recommended)

Use application-specific variable files for consistent, maintainable deployments:

```bash
# Create application variables
cp vars/example-app.yml vars/neodatabase.yml
# Edit vars/neodatabase.yml with your settings

# Deploy environment and application
ansible-playbook -i inventory/hosts.yml site.yml -e "app_name=neodatabase"
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "app_name=neodatabase"
```

### Mode 2: Generic Environment Setup

Setup a generic Laravel environment without application-specific variables:

```bash
# Setup environment only
ansible-playbook -i inventory/hosts.yml site.yml

# Deploy later with specific configuration
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "laravel_deploy_repo=https://github.com/user/app.git"
```

### Mode 3: Quick Development Setup

For rapid development environment setup:

```bash
ansible-playbook -i inventory/hosts.yml quick-install.yml
```

## Customizing the Stack

### Database Engine

Set the database engine in your application variables or via command line:

```bash
# In vars/myapp.yml
db_engine: postgresql  # Options: mysql, mariadb, postgresql

# Or via command line
ansible-playbook -i inventory/hosts.yml site.yml -e "app_name=myapp" -e "db_engine=postgresql"
```

### Redis Cache

Enable Redis in your application variables:

```yaml
# In vars/myapp.yml
enable_redis: true
redis_maxmemory: "512mb"
redis_requirepass: "secure_redis_password"
```

### Web Server

Choose between Nginx and Apache:

```yaml
# In vars/myapp.yml
webserver_type: nginx  # Options: nginx, apache
webserver_enable_ssl: true
webserver_ssl_certificate: "/path/to/cert.crt"
webserver_ssl_certificate_key: "/path/to/private.key"
```

### PHP Configuration

Customize PHP settings for your application:

```yaml
# In vars/myapp.yml
php_memory_limit: "512M"
php_max_execution_time: 300
php_timezone: "Europe/Paris"
```

## Multiple Applications

Deploy multiple Laravel applications on the same server:

```bash
# Setup environment (once)
ansible-playbook -i inventory/hosts.yml site.yml -e "app_name=app1"

# Deploy multiple applications
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "app_name=app1"
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "app_name=app2"
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "app_name=app3"
```

Each application gets its own:
- Installation directory
- Database
- Virtual host configuration
- Environment variables

## Maintenance Tasks

Run Laravel maintenance tasks:

```bash
# Run migrations
ansible-playbook -i inventory/hosts.yml laravel-maintenance.yml -e "maintenance_task=migrate" -e "app_name=myapp"

# Clear cache
ansible-playbook -i inventory/hosts.yml laravel-maintenance.yml -e "maintenance_task=clear-cache" -e "app_name=myapp"

# Put in maintenance mode
ansible-playbook -i inventory/hosts.yml laravel-maintenance.yml -e "maintenance_task=down" -e "app_name=myapp"

# Take out of maintenance mode
ansible-playbook -i inventory/hosts.yml laravel-maintenance.yml -e "maintenance_task=up" -e "app_name=myapp"
```

## Security Hardening

Secure your servers for production:

```bash
ansible-playbook -i inventory/hosts.yml security-hardening.yml
```

This configures:
- SSH security (disable root login, key-only auth)
- Firewall (UFW) with minimal open ports
- Fail2Ban for intrusion prevention
- PHP security settings
- Web server security headers

## Using Tags

Install specific components only:

```bash
# Install only PHP and Composer
ansible-playbook -i inventory/hosts.yml site.yml --tags "php,composer" -e "app_name=myapp"

# Install only database
ansible-playbook -i inventory/hosts.yml site.yml --tags "database" -e "app_name=myapp"

# Skip Redis installation
ansible-playbook -i inventory/hosts.yml site.yml --skip-tags "redis" -e "app_name=myapp"
```

## Environment Variables

### Required Variables (Application-Specific Mode)

Each application variable file must include:

- `app_name`: Application identifier
- `webserver_server_name`: Domain name
- `webserver_laravel_root`: Installation path
- `app_repo_url`: Git repository URL
- `app_repo_branch`: Git branch
- Database credentials (based on chosen engine)

### Optional Variables

- `enable_redis`: Enable Redis (default: false)
- `webserver_type`: nginx or apache (default: nginx)
- `webserver_enable_ssl`: Enable HTTPS (default: false)
- `laravel_app_env`: Environment (default: production)
- `php_memory_limit`: PHP memory limit (default: 256M)

### Security Note

**Important**: Change default passwords in your application variable files:

```yaml
# In vars/myapp.yml
mysql_root_password: "CHANGE_ME_secure_root_password!"
mysql_db_password: "CHANGE_ME_secure_app_password!"
```

Consider using Ansible Vault to encrypt sensitive variables:

```bash
ansible-vault encrypt vars/myapp.yml
ansible-playbook -i inventory/hosts.yml site.yml -e "app_name=myapp" --ask-vault-pass
```

## Examples

### Production Laravel Application

```yaml
# vars/production-app.yml
app_name: "production-app"
laravel_app_env: "production"
webserver_server_name: "app.company.com"
webserver_enable_ssl: true
db_engine: "postgresql"
enable_redis: true
php_memory_limit: "512M"
```

### Development Environment

```yaml
# vars/dev-app.yml
app_name: "dev-app"
laravel_app_env: "local"
laravel_app_debug: "true"
webserver_server_name: "dev-app.local"
db_engine: "mysql"
enable_redis: false
```

### Staging Environment

```yaml
# vars/staging-app.yml
app_name: "staging-app"
laravel_app_env: "staging"
webserver_server_name: "staging.company.com"
db_engine: "mysql"
enable_redis: true
```

## Troubleshooting

### Common Issues

1. **Application variable file not found**
   ```
   ❌ Application variable file not found: vars/myapp.yml
   ```
   Create the file using `vars/example-app.yml` as template.

2. **Database connection failed**
   - Verify database credentials in your variable file
   - Check if database service is running
   - Ensure firewall allows database connections

3. **Permission errors**
   - Verify SSH access and sudo privileges
   - Check Laravel storage directory permissions

### Debug Mode

Enable verbose output:

```bash
ansible-playbook -i inventory/hosts.yml site.yml -e "app_name=myapp" -vvv
```

### Dry Run

Test without making changes:

```bash
ansible-playbook -i inventory/hosts.yml site.yml -e "app_name=myapp" --check
```

## Advanced Usage

### CI/CD Integration

Example GitHub Actions workflow:

```yaml
name: Deploy Laravel Application

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Deploy to Production
        run: |
          ansible-playbook -i inventory/production.yml site.yml -e "app_name=myapp"
          ansible-playbook -i inventory/production.yml deploy-laravel.yml -e "app_name=myapp"
```

### Multi-Environment Deployment

```bash
# Development
ansible-playbook -i inventory/dev.yml site.yml -e "app_name=myapp" -e "laravel_app_env=development"

# Staging
ansible-playbook -i inventory/staging.yml site.yml -e "app_name=myapp" -e "laravel_app_env=staging"

# Production
ansible-playbook -i inventory/prod.yml site.yml -e "app_name=myapp" -e "laravel_app_env=production"
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure all tasks pass `ansible-lint`
5. Submit a pull request

## Documentation

- [Application-Specific Variables Guide](docs/application-variables.md)
- [Laravel 11 Deployment Guide](docs/Laravel11-Ansible-Deployment-Guide.md)
- [Usage Guide (French)](usage-guide.md)

## License

Apache License 2.0

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review the documentation
3. Open an issue on GitHub

---

**Example Command for Your Use Case:**

```bash
ansible-playbook -i inventory/hosts.yml -l fr-ne0-web01 site.yml -e "app_name=neodatabase"
```

This will automatically load variables from `vars/neodatabase.yml` and deploy the neodatabase application to the fr-ne0-web01 server.