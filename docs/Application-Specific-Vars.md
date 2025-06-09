# Application-Specific Variables Usage Guide

This guide explains how to use application-specific variable files with the Laravel Ansible deployment system.

## 🎯 Overview

The enhanced playbook system supports application-specific variable files that allow you to:
- Deploy multiple Laravel applications to the same server with different configurations
- Maintain separate configuration files for each application
- Ensure consistency across deployments
- Version control application-specific settings

## 📁 File Structure

```
ansible-laravel/
├── site.yml                    # Main environment setup playbook
├── deploy-laravel.yml          # Application deployment playbook
├── inventory/
│   └── hosts.yml
├── group_vars/
│   └── all.yml                 # Global defaults
├── vars/
│   ├── versions.yml            # Laravel version mappings
│   ├── example-app.yml         # Template for new applications
│   ├── neodatabase.yml         # Example application configuration
│   └── myproject.yml           # Your application configuration
└── roles/
    └── ...
```

## 🚀 Usage Examples

### 1. Environment Setup with Application Variables

```bash
# Setup environment for a specific application
ansible-playbook -i inventory/hosts.yml -l fr-ne0-web01 site.yml -e "app_name=neodatabase"
```

### 2. Application Deployment

```bash
# Deploy the neodatabase application
ansible-playbook -i inventory/hosts.yml -l fr-ne0-web01 deploy-laravel.yml -e "app_name=neodatabase"
```

### 3. Combined Environment Setup and Deployment

```bash
# Setup environment and deploy application in one go
ansible-playbook -i inventory/hosts.yml -l fr-ne0-web01 site.yml -e "app_name=neodatabase"
ansible-playbook -i inventory/hosts.yml -l fr-ne0-web01 deploy-laravel.yml -e "app_name=neodatabase"
```

## 📝 Creating Application Variable Files

### Step 1: Copy the Template

```bash
cp vars/example-app.yml vars/myproject.yml
```

### Step 2: Customize Your Application Variables

Edit `vars/myproject.yml` with your application-specific settings:

```yaml
---
# Application Identity
app_name: "myproject"
app_display_name: "My Laravel Project"

# Web Server Configuration
webserver_server_name: "myproject.example.com"
webserver_laravel_root: "/var/www/myproject"

# Application Repository
app_repo_url: "https://github.com/mycompany/myproject.git"
app_repo_branch: "main"

# Database Configuration
db_engine: "postgresql"
postgresql_db_name: "myproject"
postgresql_db_user: "myproject_user"
postgresql_db_password: "secure_password_here!"

# ... other configurations
```

### Step 3: Deploy

```bash
ansible-playbook -i inventory/hosts.yml site.yml -e "app_name=myproject"
```

## 🔧 Required Variables

Each application variable file must include these required variables:

### Mandatory Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `app_name` | Application identifier | `"neodatabase"` |
| `webserver_server_name` | Domain name | `"app.example.com"` |
| `webserver_laravel_root` | Installation path | `"/var/www/app"` |
| `app_repo_url` | Git repository URL | `"https://github.com/user/app.git"` |
| `app_repo_branch` | Git branch | `"main"` |

### Database Variables (choose one engine)

#### For MySQL:
```yaml
db_engine: "mysql"
mysql_db_name: "app_database"
mysql_db_user: "app_user"
mysql_db_password: "secure_password"
mysql_root_password: "root_password"
```

#### For PostgreSQL:
```yaml
db_engine: "postgresql"
postgresql_db_name: "app_database"
postgresql_db_user: "app_user"
postgresql_db_password: "secure_password"
postgresql_admin_password: "admin_password"
```

#### For MariaDB:
```yaml
db_engine: "mariadb"
mariadb_db_name: "app_database"
mariadb_db_user: "app_user"
mariadb_db_password: "secure_password"
mariadb_root_password: "root_password"
```

## 🎛️ Advanced Configuration Options

### SSL/HTTPS Configuration

```yaml
webserver_enable_ssl: true
webserver_ssl_certificate: "/etc/ssl/certs/app.crt"
webserver_ssl_certificate_key: "/etc/ssl/private/app.key"
```

### Redis Configuration

```yaml
enable_redis: true
redis_requirepass: "redis_password"
redis_maxmemory: "512mb"
```

### Custom Environment Variables

```yaml
laravel_custom_env_vars:
  - key: "API_KEY"
    value: "your-api-key"
  - key: "EXTERNAL_SERVICE_URL"
    value: "https://api.service.com"
```

### Performance Tuning

```yaml
php_memory_limit: "512M"
php_max_execution_time: 300
laravel_opcache_enable: true
laravel_config_cache: true
```

## 🔄 Deployment Workflow

### Complete Application Setup Workflow

```bash
# 1. Setup the server environment
ansible-playbook -i inventory/hosts.yml -l fr-ne0-web01 site.yml -e "app_name=neodatabase"

# 2. Deploy the application
ansible-playbook -i inventory/hosts.yml -l fr-ne0-web01 deploy-laravel.yml -e "app_name=neodatabase"

# 3. Run maintenance tasks (if needed)
ansible-playbook -i inventory/hosts.yml -l fr-ne0-web01 laravel-maintenance.yml -e "maintenance_task=migrate" -e "app_name=neodatabase"
```

### Update Deployment

```bash
# Deploy latest changes
ansible-playbook -i inventory/hosts.yml -l fr-ne0-web01 deploy-laravel.yml -e "app_name=neodatabase"
```

### Environment-Specific Deployments

```bash
# Staging environment
ansible-playbook -i inventory/staging.yml deploy-laravel.yml -e "app_name=neodatabase" -e "laravel_app_env=staging"

# Production environment
ansible-playbook -i inventory/production.yml deploy-laravel.yml -e "app_name=neodatabase" -e "laravel_app_env=production"
```

## 🏗️ Multi-Application Server

You can deploy multiple applications on the same server:

```bash
# Deploy first application
ansible-playbook -i inventory/hosts.yml site.yml -e "app_name=neodatabase"
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "app_name=neodatabase"

# Deploy second application (reuses existing environment)
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "app_name=myproject"
```

Each application will have its own:
- Installation directory
- Database
- Virtual host configuration
- Environment file

## 🔍 Validation and Error Handling

The playbook includes comprehensive validation:

### File Existence Check
```
❌ Application variable file not found: vars/neodatabase.yml

Please create the file vars/neodatabase.yml with your application-specific variables.
You can use vars/example-app.yml as a template.
```

### Required Variables Check
```
❌ Required variables missing in vars/neodatabase.yml:
- webserver_server_name: Domain name for the application
- webserver_laravel_root: Path where the application will be installed
- app_repo_url: Git repository URL
```

### Laravel Version Compatibility
```
❌ Laravel version 12 is not supported. Available: ['10', '11']
```

## 📋 Best Practices

### 1. Security
- Never commit passwords in plain text
- Use Ansible Vault for sensitive data:
  ```bash
  ansible-vault encrypt vars/neodatabase.yml
  ansible-playbook -i inventory/hosts.yml site.yml -e "app_name=neodatabase" --ask-vault-pass
  ```

### 2. Version Control
- Keep application variable files in version control
- Use different branches for different environments
- Tag releases for rollback capability

### 3. Documentation
- Document custom variables in your application files
- Include deployment instructions in your repository
- Maintain a changelog for configuration changes

### 4. Testing
- Test deployments in staging first
- Use the `--check` flag for dry runs:
  ```bash
  ansible-playbook -i inventory/hosts.yml site.yml -e "app_name=neodatabase" --check
  ```

## 🐛 Troubleshooting

### Common Issues

1. **Variable file not found**
   - Ensure the file exists: `vars/your-app-name.yml`
   - Check the app_name parameter matches the filename

2. **Database connection failed**
   - Verify database credentials in your variable file
   - Ensure the database service is running
   - Check firewall settings

3. **Git clone failed**
   - Verify repository URL and branch
   - Check SSH keys for private repositories
   - Ensure Git is installed on target server

4. **Permission errors**
   - Verify webserver user ownership
   - Check Laravel storage directory permissions
   - Ensure writable directories are correctly set

### Debug Mode

Enable verbose output for troubleshooting:

```bash
ansible-playbook -i inventory/hosts.yml site.yml -e "app_name=neodatabase" -vvv
```

## 📚 Additional Resources

- [Laravel 11 Documentation](https://laravel.com/docs/11.x)
- [Ansible Best Practices](https://docs.ansible.com/ansible/latest/user_guide/playbooks_best_practices.html)
- [Laravel Deployment Guide](https://laravel.com/docs/11.x/deployment)

## 🤝 Contributing

To add support for new features or improve the application variable system:

1. Update the example template: `vars/example-app.yml`
2. Modify the playbook validation in `site.yml`
3. Update this documentation
4. Test with multiple applications