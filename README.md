# Ansible Laravel 11 Deployment - Simplified Architecture

This Ansible project automates the deployment of all dependencies required to run a Laravel 11 environment with **clear separation of concerns** between environment setup and application deployment.

## 🏗️ **Architecture Overview**

The project follows a **modular, maintainable architecture** with separated responsibilities:

```
ansible-laravel/
├── site.yml                    # 🏗️ Environment setup ONLY
├── deploy-laravel.yml          # 🚀 Application deployment ONLY  
├── environment-maintenance.yml # 🔧 Environment maintenance tasks
├── laravel-maintenance.yml     # 📱 Application maintenance tasks
├── security-hardening.yml      # 🔐 Security configuration
├── quick-install.yml           # ⚡ Rapid development setup
├── inventory/                  # 📊 Server inventory
├── group_vars/                 # 🌐 Environment variables
├── vars/                       # 📝 Application-specific variables
└── roles/                      # 🧩 Modular components
```

## 🎯 **Playbook Responsibilities**

| Playbook | Purpose | What it does | What it does NOT do |
|----------|---------|--------------|---------------------|
| **site.yml** | Environment Setup | Installs PHP, Composer, Node.js, Database, Redis, Web server | ❌ Deploy applications<br>❌ Manage Laravel code<br>❌ Configure .env files |
| **deploy-laravel.yml** | Application Deployment | Clone/update code, install dependencies, run migrations, build assets | ❌ Install system packages<br>❌ Configure services<br>❌ Setup databases |
| **environment-maintenance.yml** | System Maintenance | Update packages, restart services, cleanup logs, security checks | ❌ Laravel-specific tasks<br>❌ Application code updates |
| **laravel-maintenance.yml** | App Maintenance | Laravel cache, migrations, queue management, maintenance mode | ❌ System updates<br>❌ Service configuration |

## 🚀 **Quick Start**

### 1. **Setup Laravel Environment** (One-time per server)

```bash
# Install all Laravel 11 prerequisites
ansible-playbook -i inventory/hosts.yml site.yml
```

This installs:
- ✅ PHP 8.2+ with all required extensions
- ✅ Composer latest
- ✅ Node.js 20.x LTS
- ✅ Database (MySQL/MariaDB/PostgreSQL)
- ✅ Redis (optional)
- ✅ Web server (Nginx/Apache)

### 2. **Deploy Laravel Application** (Per application)

```bash
# Create application variables
cp vars/example-app.yml vars/myapp.yml
# Edit vars/myapp.yml with your settings

# Deploy application
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "app_name=myapp"
```

This deploys:
- ✅ Application code from Git
- ✅ Composer dependencies
- ✅ NPM packages and asset compilation
- ✅ Database migrations
- ✅ Laravel optimization (cache, config, routes, views)
- ✅ Proper file permissions

## 📋 **Supported Configurations**

### **Operating Systems**
- RHEL-like 8 & 9 (AlmaLinux, RockyLinux, OracleLinux)
- Debian 11 & 12
- Ubuntu 20.04, 22.04, 24.04

### **Database Engines**
```yaml
db_engine: mysql      # MySQL 8.0+
db_engine: mariadb    # MariaDB 10.11+
db_engine: postgresql # PostgreSQL 15+
```

### **Web Servers**
```yaml
webserver_type: nginx   # Nginx 1.24+ (default)
webserver_type: apache  # Apache 2.4+
```

### **Optional Components**
```yaml
enable_redis: true     # Redis 7.0+ for caching/sessions
enable_ssl: true       # HTTPS with custom certificates
```

## 🎛️ **Configuration**

### **Environment Variables** (`group_vars/all.yml`)
Controls the **environment setup** only:

```yaml
laravel_version: "11"
db_engine: "mysql"
webserver_type: "nginx"
enable_redis: false

# Database credentials (required)
mysql_root_password: "secure_root_password"

# PHP configuration
php_memory_limit: "256M"
php_timezone: "UTC"
```

### **Application Variables** (`vars/app-name.yml`)
Controls the **application deployment** only:

```yaml
app_name: "myapp"
webserver_server_name: "myapp.example.com"
webserver_laravel_root: "/var/www/myapp"
app_repo_url: "https://github.com/user/myapp.git"
app_repo_branch: "main"

# Application database settings
mysql_db_name: "myapp"
mysql_db_user: "myapp_user"
mysql_db_password: "secure_app_password"
```

## 📝 **Usage Examples**

### **Basic Environment Setup**

```bash
# MySQL + Nginx + No Redis
ansible-playbook -i inventory/hosts.yml site.yml

# PostgreSQL + Apache + Redis
ansible-playbook -i inventory/hosts.yml site.yml \
  -e "db_engine=postgresql" \
  -e "webserver_type=apache" \
  -e "enable_redis=true"
```

### **Multiple Applications on Same Server**

```bash
# 1. Setup environment once
ansible-playbook -i inventory/hosts.yml site.yml

# 2. Deploy multiple applications
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "app_name=app1"
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "app_name=app2"
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "app_name=app3"
```

Each application gets:
- ✅ Separate directory (`/var/www/app1`, `/var/www/app2`, etc.)
- ✅ Separate database
- ✅ Separate virtual host
- ✅ Separate .env configuration

### **Development vs Production**

```bash
# Development environment
ansible-playbook -i inventory/dev.yml site.yml \
  -e "environment_type=development" \
  -e "create_test_files=true"

# Production environment  
ansible-playbook -i inventory/prod.yml site.yml \
  -e "environment_type=production" \
  -e "create_test_files=false"
```

## 🔧 **Maintenance Operations**

### **Environment Maintenance**

```bash
# Check system status
ansible-playbook -i inventory/hosts.yml environment-maintenance.yml -e "maintenance_task=status"

# Update system packages
ansible-playbook -i inventory/hosts.yml environment-maintenance.yml -e "maintenance_task=update"

# Restart all services
ansible-playbook -i inventory/hosts.yml environment-maintenance.yml -e "maintenance_task=restart"

# Cleanup logs and temp files
ansible-playbook -i inventory/hosts.yml environment-maintenance.yml -e "maintenance_task=clean"

# Security check
ansible-playbook -i inventory/hosts.yml environment-maintenance.yml -e "maintenance_task=security"

# Full maintenance (all tasks)
ansible-playbook -i inventory/hosts.yml environment-maintenance.yml -e "maintenance_task=all"
```

### **Application Maintenance**

```bash
# Put application in maintenance mode
ansible-playbook -i inventory/hosts.yml laravel-maintenance.yml \
  -e "maintenance_task=down" -e "app_name=myapp"

# Run migrations
ansible-playbook -i inventory/hosts.yml laravel-maintenance.yml \
  -e "maintenance_task=migrate" -e "app_name=myapp"

# Clear application cache
ansible-playbook -i inventory/hosts.yml laravel-maintenance.yml \
  -e "maintenance_task=clear-cache" -e "app_name=myapp"

# Restart queue workers
ansible-playbook -i inventory/hosts.yml laravel-maintenance.yml \
  -e "maintenance_task=restart-queue" -e "app_name=myapp"

# Exit maintenance mode
ansible-playbook -i inventory/hosts.yml laravel-maintenance.yml \
  -e "maintenance_task=up" -e "app_name=myapp"
```

## 🏷️ **Using Tags for Selective Installation**

Install only specific components:

```bash
# Install only PHP and Composer
ansible-playbook -i inventory/hosts.yml site.yml --tags "php,composer"

# Install only database
ansible-playbook -i inventory/hosts.yml site.yml --tags "database"

# Install everything except Redis
ansible-playbook -i inventory/hosts.yml site.yml --skip-tags "redis"

# Available tags: php, composer, nodejs, database, mysql, mariadb, postgresql, redis, webserver, nginx, apache
```

## 🔐 **Security**

### **Secure Password Management**

```bash
# Use Ansible Vault for sensitive data
ansible-vault create group_vars/all/vault.yml

# Add encrypted passwords
vault_mysql_root_password: "super_secure_password"
vault_mysql_db_password: "app_secure_password"

# Reference in group_vars/all.yml
mysql_root_password: "{{ vault_mysql_root_password }}"
mysql_db_password: "{{ vault_mysql_db_password }}"

# Deploy with vault
ansible-playbook -i inventory/hosts.yml site.yml --ask-vault-pass
```

### **Production Security**

```bash
# Apply security hardening
ansible-playbook -i inventory/hosts.yml security-hardening.yml

# Security features:
# ✅ SSH hardening (disable root, key-only auth)
# ✅ Firewall (UFW) configuration
# ✅ Fail2Ban for intrusion prevention  
# ✅ PHP security settings
# ✅ Web server security headers
```

## 🧪 **Testing and Verification**

### **Environment Verification**

After running `site.yml`, verify the environment:

```bash
# Check all services
sudo systemctl status nginx php8.2-fpm mysql

# Test PHP
php -v
composer --version
node --version

# Test database connection
mysql -u root -p -e "SELECT version();"

# Test web server (if test files created)
curl http://your-server/phpinfo.php
```

### **Application Verification**

After running `deploy-laravel.yml`:

```bash
# Check application
curl http://your-app-domain

# Check Laravel status
cd /var/www/myapp && php artisan --version

# Check database connection
cd /var/www/myapp && php artisan db:show

# Check queue status
cd /var/www/myapp && php artisan queue:work --once
```

## 🐛 **Troubleshooting**

### **Common Issues**

1. **Permission Errors**
   ```bash
   # Fix Laravel permissions
   ansible-playbook -i inventory/hosts.yml site.yml --tags "permissions"
   ```

2. **Service Not Starting**
   ```bash
   # Check service status
   ansible-playbook -i inventory/hosts.yml environment-maintenance.yml -e "maintenance_task=status"
   
   # Restart services
   ansible-playbook -i inventory/hosts.yml environment-maintenance.yml -e "maintenance_task=restart"
   ```

3. **Database Connection Failed**
   ```bash
   # Verify database configuration
   mysql -u root -p -e "SHOW DATABASES;"
   
   # Check user permissions
   mysql -u myapp_user -p myapp -e "SELECT 1;"
   ```

### **Debug Mode**

```bash
# Enable verbose output
ansible-playbook -i inventory/hosts.yml site.yml -vvv

# Dry run (check mode)
ansible-playbook -i inventory/hosts.yml site.yml --check

# Show differences
ansible-playbook -i inventory/hosts.yml site.yml --check --diff
```

## 📚 **Advanced Features**

### **Multi-Environment Deployment**

```bash
# Development
ansible-playbook -i inventory/dev.yml site.yml -e "laravel_app_env=development"

# Staging  
ansible-playbook -i inventory/staging.yml site.yml -e "laravel_app_env=staging"

# Production
ansible-playbook -i inventory/prod.yml site.yml -e "laravel_app_env=production"
```

### **Performance Tuning**

```yaml
# group_vars/production.yml
php_memory_limit: "512M"
php_opcache_memory_consumption: 512
mysql_innodb_buffer_pool_size: "2G"
redis_maxmemory: "1gb"
nginx_worker_processes: "auto"
nginx_worker_connections: 2048
```

### **Backup Configuration**

```bash
# Enable automatic backups
ansible-playbook -i inventory/hosts.yml environment-maintenance.yml -e "maintenance_task=backup"

# Schedule regular backups via cron
enable_database_backups: true
backup_schedule: "0 2 * * *"  # Daily at 2 AM
backup_retention_days: 7
```

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Make your changes following the architecture principles
4. Ensure `ansible-lint` passes
5. Test on supported distributions
6. Submit a pull request

## 📖 **Documentation**

- [Application-Specific Variables Guide](docs/Application-Specific-Vars.md)
- [Laravel 11 Deployment Guide](docs/Laravel11-Ansible-Deployment-Guide.md)
- [Usage Guide (French)](usage-guide.md)

## 🎯 **Benefits of This Architecture**

### **✅ Maintainability**
- Clear separation of environment vs application concerns
- Easier to debug and troubleshoot issues
- Modular roles can be updated independently

### **✅ Flexibility**
- Deploy multiple applications on same server
- Mix different Laravel versions
- Easy environment updates without affecting applications

### **✅ Reliability**
- Environment setup is idempotent
- Application deployments preserve existing data
- Rollback capabilities for applications

### **✅ Scalability**
- Environment setup once, deploy many applications
- Easy to add new servers to inventory
- Performance tuning separated from functionality

## 📄 **License**

Apache License 2.0

---

**🚀 Quick Example:**

```bash
# Setup environment (once per server)
ansible-playbook -i inventory/hosts.yml site.yml

# Deploy application (per app)
cp vars/example-app.yml vars/myapp.yml
# Edit vars/myapp.yml
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "app_name=myapp"

# Your Laravel application is now live! 🎉
```