# Laravel 11 Ansible Deployment Guide

This guide provides an overview of the Ansible playbook structure for deploying a Laravel 11 environment and offers recommendations for production use.

## Overview of the Ansible Project

This Ansible project provides:

1. **Environment Setup**: Automation for installing all Laravel 11 prerequisites on various Linux distributions
2. **Flexibility**: Support for different database engines, web servers, and optional components
3. **Security**: Best practices for securing your Laravel environment
4. **Maintenance**: Tools for managing Laravel applications post-deployment

## Key Playbooks

- `site.yml`: Main playbook for setting up the Laravel server environment
- `deploy-laravel.yml`: Playbook for deploying a Laravel application
- `laravel-maintenance.yml`: Utility playbook for common Laravel maintenance tasks
- `security-hardening.yml`: Playbook for securing the server

## Production Recommendations

### 1. Security

- **Use Ansible Vault**: Encrypt sensitive variables (passwords, keys) with Ansible Vault
  ```bash
  ansible-vault encrypt group_vars/production.yml
  ```

- **Apply Security Hardening**: Run the security-hardening.yml playbook
  ```bash
  ansible-playbook -i inventory/production.yml security-hardening.yml
  ```

- **Use SSL/TLS**: Enable SSL for production environments
  ```yaml
  webserver_enable_ssl: true
  webserver_ssl_certificate: /path/to/cert.crt
  webserver_ssl_certificate_key: /path/to/private.key
  ```

### 2. Performance Tuning

- **PHP Configuration**: Adjust PHP settings based on server resources
  ```yaml
  php_memory_limit: "512M"  # Increase for memory-intensive applications
  php_max_execution_time: 120
  php_opcache_memory_consumption: 256  # Increase for larger applications
  ```

- **Database Tuning**: Optimize database settings for production
  ```yaml
  mysql_innodb_buffer_pool_size: "2G"  # Adjust based on available RAM
  mysql_max_connections: 300  # Adjust based on expected load
  ```

- **Web Server Tuning**: Configure web server for high performance
  ```yaml
  webserver_worker_processes: "auto"
  webserver_worker_connections: 2048
  ```

- **Enable Redis**: Use Redis for caching, sessions, and queues
  ```yaml
  enable_redis: true
  redis_maxmemory: "1gb"
  ```

### 3. Deployment Strategy

- **Zero-Downtime Deployment**: Use maintenance mode and queue workers
  ```bash
  # Put application in maintenance mode
  ansible-playbook -i inventory/production.yml laravel-maintenance.yml -e "maintenance_task=down"
  
  # Deploy application
  ansible-playbook -i inventory/production.yml deploy-laravel.yml
  
  # Restart queue workers
  ansible-playbook -i inventory/production.yml laravel-maintenance.yml -e "maintenance_task=restart-queue"
  
  # Take application out of maintenance mode
  ansible-playbook -i inventory/production.yml laravel-maintenance.yml -e "maintenance_task=up"
  ```

- **Use CI/CD Pipeline**: Automate deployment with GitHub Actions or similar tools

### 4. Monitoring and Maintenance

- **Regular Updates**: Keep the system and dependencies updated
  ```bash
  ansible-playbook -i inventory/production.yml site.yml --tags common
  ```

- **Database Backups**: Implement regular database backups
- **Log Rotation**: Configure log rotation for Laravel logs
- **Consider Monitoring Tools**: Use tools like New Relic, Datadog, or open-source alternatives

## Extending the Playbook

The modular structure allows easy extension of the playbook:

- **Add New Roles**: For additional services (e.g., Elasticsearch, Memcached)
- **Create Custom Variables**: Override defaults in group_vars or host_vars
- **Integration with CDNs**: Add tasks for integrating with CDN services
- **Add Custom Tasks**: Extend roles with additional tasks

## Troubleshooting

Common issues and solutions:

1. **Permission Problems**: Ensure the web server user has proper permissions to Laravel storage and bootstrap/cache directories
2. **Database Connection Issues**: Verify database credentials and access permissions
3. **Web Server Configuration**: Check the web server configuration for any syntax errors
4. **PHP Extensions**: Ensure all required PHP extensions are installed

When troubleshooting, inspect logs at:
- `/var/log/nginx/error.log` or `/var/log/apache2/error.log`
- `/var/log/php*.log`
- `storage/logs/laravel.log` in your Laravel application directory