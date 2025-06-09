# Laravel Deploy Role

This role handles the deployment of Laravel applications following the official Laravel 11 deployment guidelines.

## 🎯 Purpose

The `laravel_deploy` role is responsible for:
- Cloning/updating application code from Git
- Installing dependencies via Composer and NPM
- Configuring the Laravel application
- Running database migrations
- Optimizing the application for production
- Setting proper file permissions

## 📋 Deployment Order

The role follows the correct Laravel deployment sequence:

### 1. Git Deployment (`git_deploy.yml`)
- Clone or update repository
- Set up directory structure
- Configure Git safe directories

### 2. Pre-Build Configuration (`pre_configure.yml`)
- Create storage directories
- Set basic environment variables
- Set initial file permissions

### 3. Build Dependencies (`build.yml`)
- **`composer install`** - Install PHP dependencies
- **`npm ci && npm run build`** - Install and build frontend assets
- Verify Laravel installation

### 4. Post-Build Configuration (`configure.yml`)
- Generate complete `.env` file
- **`php artisan key:generate`** - Generate application key
- **`php artisan migrate`** - Run database migrations
- **`php artisan storage:link`** - Create storage symlink

### 5. Optimization (`optimize.yml`)
- Clear existing caches
- Cache configuration, routes, views, events
- Optimize Composer autoloader
- Run health checks

### 6. Finalization (`finalize.yml`)
- Set final file permissions
- Security cleanup
- Deployment logging

## ⚠️ Important Notes

### Why This Order Matters

**Issue**: Running `php artisan` commands before `composer install` will fail because Laravel's `artisan` script requires `vendor/autoload.php` which doesn't exist until Composer dependencies are installed.

**Solution**: The role ensures that:
1. `composer install` runs first to create the `vendor/` directory
2. Only then can `php artisan` commands be executed safely

### Laravel 11 Compliance

This deployment order follows the official Laravel 11 documentation:
- ✅ Install dependencies first
- ✅ Configure application second
- ✅ Optimize for production last

## 🔧 Variables

### Required Variables
```yaml
app_name: "myapp"
webserver_server_name: "myapp.example.com"
webserver_laravel_root: "/var/www/myapp"
app_repo_url: "https://github.com/user/myapp.git"
app_repo_branch: "main"
```

### Database Variables
```yaml
laravel_app_db_connection: "mysql"
laravel_app_db_database: "myapp"
laravel_app_db_username: "myapp_user"
laravel_app_db_password: "secure_password"
```

### Deployment Behavior
```yaml
laravel_deploy_migrate: true        # Run migrations
laravel_deploy_seed: false          # Run database seeder
laravel_deploy_build_assets: true   # Build frontend assets
laravel_deploy_optimize: true       # Optimize for production
```

## 🏷️ Tags

You can run specific parts of the deployment:

```bash
# Only Git operations
ansible-playbook deploy-laravel.yml --tags "git"

# Only build dependencies
ansible-playbook deploy-laravel.yml --tags "build"

# Only configuration
ansible-playbook deploy-laravel.yml --tags "configure"

# Only optimization
ansible-playbook deploy-laravel.yml --tags "optimize"
```

## 🐛 Troubleshooting

### Common Issues

1. **`vendor/autoload.php` not found**
   - **Cause**: Trying to run `artisan` commands before `composer install`
   - **Solution**: This role fixes the order automatically

2. **Permission errors**
   - **Cause**: Incorrect file ownership
   - **Solution**: The role sets proper permissions in multiple steps

3. **Database connection errors**
   - **Cause**: Database not configured or credentials wrong
   - **Solution**: Verify database variables and ensure database server is running

### Debug Mode

```bash
# Run with verbose output
ansible-playbook deploy-laravel.yml -e "app_name=myapp" -vvv

# Check specific task
ansible-playbook deploy-laravel.yml -e "app_name=myapp" --tags "build" -vvv
```

## 📚 Integration

This role is designed to work with the main `site.yml` playbook:

1. **First**: Run `site.yml` to set up the Laravel environment
2. **Then**: Run `deploy-laravel.yml` to deploy your application

```bash
# Setup environment
ansible-playbook -i inventory/hosts.yml site.yml

# Deploy application
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml -e "app_name=myapp"
```

## ✅ Success Indicators

A successful deployment will show:
- ✅ Git repository cloned/updated
- ✅ Composer dependencies installed
- ✅ NPM packages installed (if package.json exists)
- ✅ Assets compiled (if build scripts exist)
- ✅ Laravel application key generated
- ✅ Database migrations run
- ✅ Storage link created
- ✅ Application optimized for production

## 🔄 Re-deployment

The role is idempotent and can be run multiple times safely:
- Git will update to latest commit
- Composer will update only changed dependencies
- NPM will install only changed packages
- Database migrations will run only new migrations
- Caches will be refreshed