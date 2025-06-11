# Laravel Webserver Configuration Role

This role automatically configures the webserver (NGINX or Apache) for Laravel applications with security best practices, SSL support, and performance optimizations.

## 🎯 Purpose

The `laravel_webserver` role is responsible for:
- Creating application-specific webserver virtual host configurations
- Implementing security headers and access restrictions
- Configuring SSL/HTTPS with modern security standards
- Setting up logging and monitoring for applications
- Applying performance optimizations (caching, compression)
- Managing firewall rules for web traffic
- Validating configurations and SSL certificates

## 📋 Requirements

- NGINX or Apache must be installed (via `site.yml` playbook)
- PHP-FPM must be configured and running
- Application must be deployed (via `laravel_deploy` role)
- SSL certificates must be present if SSL is enabled

## 🔧 Variables

### Required Variables

```yaml
app_name: "myapp"                           # Application identifier
webserver_server_name: "myapp.example.com" # Primary domain
webserver_laravel_root: "/var/www/myapp"    # Laravel root directory
webserver_public_root: "/var/www/myapp/public" # Laravel public directory
```

### Basic Configuration

```yaml
webserver_type: "nginx"                     # nginx or apache
webserver_enable_ssl: false                 # Enable HTTPS
webserver_client_max_body_size: "64M"       # Upload limit
webserver_server_aliases: []                # Additional domains
```

### SSL Configuration

```yaml
webserver_enable_ssl: true
webserver_ssl_certificate: "/path/to/cert.crt"
webserver_ssl_certificate_key: "/path/to/private.key"
laravel_webserver_ssl_strict: true          # Fail if certs missing
```

### Security Configuration

```yaml
laravel_webserver_security: true            # Enable security headers
laravel_webserver_firewall: false           # Configure UFW firewall
laravel_webserver_rate_limiting: false      # Enable rate limiting
laravel_webserver_telescope_restrictions: false # Restrict Telescope access
```

### Performance Configuration

```yaml
laravel_webserver_caching: true             # Static file caching
laravel_webserver_compression: true         # Enable gzip/deflate
laravel_webserver_static_expires: "1y"      # Cache duration
```

## 🏷️ Tags

You can run specific parts of the configuration:

```bash
# SSL validation only
ansible-playbook deploy-laravel.yml --tags "ssl"

# Security configuration only
ansible-playbook deploy-laravel.yml --tags "security"

# Firewall configuration only
ansible-playbook deploy-laravel.yml --tags "firewall"

# Configuration validation only
ansible-playbook deploy-laravel.yml --tags "validate"
```

## 🌐 Webserver-Specific Features

### NGINX Features

- Rate limiting with configurable zones
- Modern SSL/TLS configuration
- Optimized FastCGI parameters
- Static file serving with optimal headers
- Security restrictions for Laravel directories

### Apache Features

- Connection limiting (if mod_limitipconn available)
- SSL configuration with modern ciphers
- PHP-FPM integration
- Security headers via mod_headers
- Virtual host isolation

## 🔒 Security Features

### Automatic Security Headers

- `X-Frame-Options: SAMEORIGIN`
- `X-Content-Type-Options: nosniff`
- `X-XSS-Protection: 1; mode=block`
- `Strict-Transport-Security` (HTTPS only)
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy` (HTTPS only)

### Protected Directories

By default, the following directories are protected:

- `.git` - Git repository files
- `.env` - Environment configuration
- `storage` - Laravel storage directory
- `bootstrap/cache` - Laravel cache directory
- `vendor` - Composer dependencies
- `node_modules` - NPM packages

### SSL/TLS Security

- Modern protocols only (TLSv1.2, TLSv1.3)
- Secure cipher suites
- Perfect Forward Secrecy
- OCSP Stapling (NGINX)
- HSTS with configurable max-age

## 🔥 Firewall Configuration

When `laravel_webserver_firewall: true`:

```yaml
# Basic firewall configuration
laravel_webserver_firewall_enable: true
laravel_webserver_firewall_block_db_ports: true # Block 3306, 5432, etc.

# Custom ports
laravel_webserver_firewall_custom_ports:
  - port: "8080"
    proto: "tcp"
    comment: "Custom application port"

# IP restrictions
laravel_webserver_firewall_ip_restrictions:
  - from_ip: "192.168.1.0/24"
    port: "443"
    rule: "allow"
    comment: "Office network HTTPS"
```

## 📊 Monitoring and Logging

### Application-Specific Logs

Each application gets separate log files:

- `/var/log/nginx/appname-access.log`
- `/var/log/nginx/appname-error.log`
- `/var/log/nginx/appname-ssl-access.log` (if SSL enabled)
- `/var/log/nginx/appname-ssl-error.log` (if SSL enabled)

### Log Rotation

Automatic log rotation is configured for application logs with:
- Daily rotation
- 52 weeks retention
- Compression after rotation
- Reload webserver after rotation

## 🧪 Testing and Validation

### Automatic Tests

The role performs these validations:

1. **Configuration Syntax**: `nginx -t` or `apache2ctl configtest`
2. **SSL Certificate Validation**: Certificate/key pair verification
3. **Directory Structure**: Laravel directory existence
4. **Service Status**: Webserver service running
5. **PHP-FPM Socket**: Socket file availability

### Manual Testing

```bash
# Test webserver configuration
sudo nginx -t
sudo apache2ctl configtest

# Test SSL certificates
openssl x509 -in /path/to/cert.crt -text -noout
openssl rsa -in /path/to/private.key -check

# Test application connectivity
curl -I https://myapp.example.com
curl -I -H "Host: myapp.example.com" http://localhost

# Check security headers
curl -I https://myapp.example.com | grep -E "(X-Frame|X-Content|Strict-Transport)"
```

## 🔄 Integration with Deploy Process

This role is automatically called by `deploy-laravel.yml`:

```yaml
roles:
  - role: laravel_deploy           # Deploy application
  - role: laravel_webserver        # Configure webserver
  - role: laravel_telescope        # Optional Telescope
```

The role expects the application to be deployed first and uses these variables from the deployment:

- Application directory structure
- PHP version and configuration
- Environment settings (production, staging, etc.)

## 📱 Multi-Application Support

The role supports multiple Laravel applications on the same server:

```bash
# Deploy first application
ansible-playbook deploy-laravel.yml -e "app_name=app1"

# Deploy second application (separate configuration)
ansible-playbook deploy-laravel.yml -e "app_name=app2"

# Each gets its own:
# - Virtual host configuration
# - Log files
# - SSL certificates
# - Security settings
```

## 🐛 Troubleshooting

### Common Issues

1. **Configuration Test Fails**
   ```bash
   # Check syntax errors
   sudo nginx -t
   sudo apache2ctl configtest
   
   # Check include paths
   grep -r "app_name" /etc/nginx/
   ```

2. **SSL Certificate Issues**
   ```bash
   # Verify certificate files exist
   ls -la /path/to/ssl/certificates/
   
   # Test certificate/key pair
   openssl x509 -noout -modulus -in cert.crt | openssl md5
   openssl rsa -noout -modulus -in private.key | openssl md5
   ```

3. **Permission Problems**
   ```bash
   # Check webserver user ownership
   ls -la /var/www/app/
   
   # Fix permissions if needed
   sudo chown -R www-data:www-data /var/www/app/
   ```

4. **Firewall Blocking Access**
   ```bash
   # Check UFW status
   sudo ufw status verbose
   
   # Temporarily disable for testing
   sudo ufw disable
   ```

### Debug Mode

Enable verbose validation:

```yaml
laravel_webserver_test_connectivity: true
laravel_webserver_fail_on_config_error: false
laravel_webserver_continue_on_warning: true
```

## 🔧 Advanced Configuration

### Custom Security Headers

```yaml
laravel_webserver_security_headers:
  x_frame_options: "DENY"
  x_content_type_options: "nosniff"
  x_xss_protection: "1; mode=block"
  referrer_policy: "no-referrer"
  permissions_policy: "geolocation=(), microphone=(), camera=(), payment=()"
```

### Rate Limiting (NGINX)

```yaml
laravel_webserver_rate_limiting: true
laravel_webserver_rate_limit: "10r/s"      # 10 requests per second
laravel_webserver_rate_burst: "20"         # Allow burst of 20
laravel_webserver_rate_zone_size: "10m"    # Memory for tracking
```

### Telescope Security

```yaml
laravel_webserver_telescope_restrictions: true
laravel_telescope_allowed_ips:
  - "192.168.1.0/24"
  - "10.0.0.100"
```

This role provides a complete, secure, and optimized webserver configuration for Laravel applications with minimal manual intervention required.