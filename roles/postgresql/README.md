# PostgreSQL Role for Laravel 11

This Ansible role installs and configures PostgreSQL for Laravel 11 applications with optimized settings for performance and security.

## Features

- ✅ PostgreSQL 15+ installation (Laravel 11 compatible)
- ✅ Automatic cluster initialization
- ✅ Laravel-optimized configuration
- ✅ Database and user creation for Laravel applications
- ✅ Security hardening with proper authentication
- ✅ Cross-platform support (Debian/Ubuntu and RHEL/CentOS)
- ✅ Performance tuning for Laravel workloads

## Requirements

- **Laravel 11 Requirements**: PostgreSQL 13.0+ (PostgreSQL 15+ recommended)
- **Operating Systems**: 
  - Debian 11/12
  - Ubuntu 20.04/22.04/24.04
  - RHEL/CentOS/AlmaLinux/Rocky Linux 8/9
- **Dependencies**: python3-psycopg2 (installed automatically)

## Role Variables

### Required Variables

These variables must be set in your inventory or group_vars:

```yaml
# PostgreSQL admin password (REQUIRED)
postgresql_admin_password: "secure_admin_password"
```

### Laravel Database Variables (Optional)

Set these to automatically create a Laravel database and user:

```yaml
# Laravel database configuration
postgresql_db_name: "laravel"
postgresql_db_user: "laravel_user"
postgresql_db_password: "secure_app_password"
postgresql_db_encoding: "UTF8"
postgresql_db_lc_collate: "en_US.UTF-8"
postgresql_db_lc_ctype: "en_US.UTF-8"
```

### Performance Tuning Variables

```yaml
# Memory settings (adjust based on your server)
postgresql_shared_buffers: "256MB"      # 25% of RAM recommended
postgresql_work_mem: "4MB"              # Per connection work memory
postgresql_maintenance_work_mem: "64MB" # Maintenance operations memory
postgresql_effective_cache_size: "1GB"  # Total memory available for caching

# Connection settings
postgresql_max_connections: 100         # Maximum concurrent connections
postgresql_port: 5432                   # PostgreSQL port

# Laravel optimizations
postgresql_laravel_optimized: true      # Enable Laravel-specific optimizations
```

### Security Variables

```yaml
# Listen addresses (localhost by default for security)
postgresql_listen_addresses: "localhost"

# Custom authentication entries (pg_hba.conf)
postgresql_hba_entries:
  - type: host
    database: "{{ postgresql_db_name }}"
    user: "{{ postgresql_db_user }}"
    address: "10.0.1.0/24"
    auth_method: md5
```

## Usage Examples

### Basic Installation

```yaml
# group_vars/all.yml
db_engine: "postgresql"
postgresql_admin_password: "secure_admin_password"

# inventory/hosts.yml
[webservers]
server1 ansible_host=192.168.1.10
```

```bash
ansible-playbook -i inventory/hosts.yml site.yml --tags postgresql
```

### Laravel Application Setup

```yaml
# vars/myapp.yml
postgresql_db_name: "myapp"
postgresql_db_user: "myapp_user"
postgresql_db_password: "secure_app_password"
postgresql_admin_password: "secure_admin_password"
```

```bash
ansible-playbook -i inventory/hosts.yml site.yml -e "app_name=myapp"
```

### Production Configuration

```yaml
# group_vars/production.yml
postgresql_version: "15"
postgresql_max_connections: 200
postgresql_shared_buffers: "2GB"
postgresql_effective_cache_size: "6GB"
postgresql_work_mem: "8MB"
postgresql_maintenance_work_mem: "256MB"
postgresql_laravel_optimized: true

# Security settings
postgresql_listen_addresses: "localhost"
postgresql_hba_entries:
  - type: host
    database: "myapp"
    user: "myapp_user"
    address: "10.0.1.100/32"
    auth_method: md5
```

## Laravel .env Configuration

After running this role, configure your Laravel application with these database settings:

```env
DB_CONNECTION=pgsql
DB_HOST=127.0.0.1
DB_PORT=5432
DB_DATABASE=your_database_name
DB_USERNAME=your_database_user
DB_PASSWORD=your_database_password
```

## Performance Recommendations

### Memory Settings

For optimal Laravel performance, configure PostgreSQL memory based on your server:

| Server RAM | shared_buffers | effective_cache_size | work_mem |
|------------|----------------|---------------------|----------|
| 1GB        | 256MB          | 512MB               | 2MB      |
| 4GB        | 1GB            | 3GB                 | 4MB      |
| 8GB        | 2GB            | 6GB                 | 8MB      |
| 16GB       | 4GB            | 12GB                | 16MB     |

### Connection Pooling

For high-traffic Laravel applications, consider using connection pooling:

```yaml
postgresql_max_connections: 200
# Use PgBouncer or similar for connection pooling
```

## Security Best Practices

1. **Use strong passwords**: Set complex passwords for `postgresql_admin_password`
2. **Restrict access**: Use `postgresql_listen_addresses` and `postgresql_hba_entries` carefully
3. **Enable SSL**: For production, enable SSL/TLS encryption
4. **Regular updates**: Keep PostgreSQL updated with security patches
5. **Monitor logs**: Review authentication and error logs regularly

## Troubleshooting

### Common Issues

#### 1. "Invalid data directory" Error

This usually happens when PostgreSQL cluster initialization fails:

```bash
# Check PostgreSQL service status
sudo systemctl status postgresql

# Check data directory permissions
sudo ls -la /var/lib/postgresql/15/main/

# Manually reinitialize if needed (DEBIAN/UBUNTU)
sudo systemctl stop postgresql
sudo rm -rf /var/lib/postgresql/15/main/*
sudo -u postgres /usr/lib/postgresql/15/bin/initdb -D /var/lib/postgresql/15/main
sudo systemctl start postgresql
```

#### 2. Connection Refused

Check if PostgreSQL is listening on the correct address:

```bash
# Check configuration
sudo grep listen_addresses /etc/postgresql/15/main/postgresql.conf

# Check if service is running
sudo systemctl status postgresql

# Check port
sudo netstat -tlnp | grep 5432
```

#### 3. Authentication Failed

Verify pg_hba.conf configuration:

```bash
# Check authentication configuration
sudo cat /etc/postgresql/15/main/pg_hba.conf

# Test connection
psql -h 127.0.0.1 -U postgres -d postgres
```

### Log Locations

- **Debian/Ubuntu**: `/var/log/postgresql/postgresql-15-main.log`
- **RHEL/CentOS**: `/var/lib/pgsql/15/data/log/`

## Dependencies

This role requires the following Python packages (installed automatically):

- `python3-psycopg2` (for Ansible PostgreSQL modules)
- `python3-pip` (for package management)

## Tags

Available tags for selective execution:

- `postgresql` - Run all PostgreSQL tasks
- `postgresql:install` - Installation only
- `postgresql:configure` - Configuration only

Example:
```bash
ansible-playbook -i inventory/hosts.yml site.yml --tags "postgresql:install"
```

## Compatibility

### PostgreSQL Versions

| Laravel Version | Minimum PostgreSQL | Recommended |
|-----------------|-------------------|-------------|
| Laravel 11      | 13.0              | 15+         |
| Laravel 10      | 11.0              | 14+         |

### Operating Systems

- ✅ **Debian 11 (Bullseye)**: PostgreSQL 13, 14, 15
- ✅ **Debian 12 (Bookworm)**: PostgreSQL 15 (default)
- ✅ **Ubuntu 20.04 LTS**: PostgreSQL 12, 13, 14, 15
- ✅ **Ubuntu 22.04 LTS**: PostgreSQL 14, 15 (default)
- ✅ **Ubuntu 24.04 LTS**: PostgreSQL 16 (but 15 recommended for Laravel 11)
- ✅ **RHEL/CentOS/AlmaLinux/Rocky Linux 8**: PostgreSQL 13, 14, 15
- ✅ **RHEL/CentOS/AlmaLinux/Rocky Linux 9**: PostgreSQL 13, 14, 15

## License

This role is part of the ansible-laravel project and follows the same Apache 2.0 license.