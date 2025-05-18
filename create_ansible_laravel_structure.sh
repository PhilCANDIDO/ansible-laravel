#!/bin/bash
# Script to organize the ansible-laravel project structure
# Author: Claude.ai
# Date: May 18, 2025

set -e  # Exit immediately if a command exits with a non-zero status

# Define colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Organizing ansible-laravel project structure...${NC}"

# Create base directories
mkdir -p inventory group_vars vars roles templates

# Create the roles subdirectories
ROLES=("php" "composer" "nodejs" "mysql" "mariadb" "postgresql" "redis" "webserver")
for role in "${ROLES[@]}"; do
    mkdir -p roles/$role/{tasks,defaults,vars,handlers,templates}
done

# Create specific template directories for webserver
mkdir -p roles/webserver/templates/{nginx,apache}

# Copy template files to their respective directories
echo -e "${GREEN}Copying template files to their directories...${NC}"

# Copy roles main files
echo "---
# php role main tasks file
- name: Include installation tasks
  ansible.builtin.include_tasks: install.yml

- name: Include configuration tasks
  ansible.builtin.include_tasks: configure.yml
  when: configure_php | default(true) | bool" > roles/php/tasks/main.yml

# Repeat for other roles...
for role in "${ROLES[@]}"; do
    if [ "$role" != "php" ]; then
        echo "---
# $role role main tasks file
- name: Include installation tasks
  ansible.builtin.include_tasks: install.yml

- name: Include configuration tasks
  ansible.builtin.include_tasks: configure.yml
  when: configure_${role} | default(true) | bool" > roles/$role/tasks/main.yml
    fi
done

# Copy the PHP role task files
cp php-role roles/php/tasks/install.yml
cp php-configure roles/php/tasks/configure.yml
cp php-defaults roles/php/defaults/main.yml
cp php-debian-vars roles/php/vars/debian.yml
cp php-redhat-vars roles/php/vars/redhat.yml
cp php-handlers roles/php/handlers/main.yml

# Copy the template files
cp php-timezone-template roles/php/templates/php-timezone.ini.j2
cp php-memory-template roles/php/templates/php-memory.ini.j2
cp php-uploads-template roles/php/templates/php-uploads.ini.j2
cp php-execution-template roles/php/templates/php-execution.ini.j2
cp php-opcache-template roles/php/templates/php-opcache.ini.j2

# Copy the Composer role files
cp composer-install roles/composer/tasks/install.yml
cp composer-configure roles/composer/tasks/configure.yml
cp composer-defaults roles/composer/defaults/main.yml

# Copy the Node.js role files
cp nodejs-install roles/nodejs/tasks/install.yml
cp nodejs-configure roles/nodejs/tasks/configure.yml
cp nodejs-defaults roles/nodejs/defaults/main.yml

# Copy the MySQL role files
cp mysql-install roles/mysql/tasks/install.yml
cp mysql-configure roles/mysql/tasks/configure.yml
cp mysql-defaults roles/mysql/defaults/main.yml
cp mysql-debian-vars roles/mysql/vars/debian.yml
cp mysql-redhat-vars roles/mysql/vars/redhat.yml
cp mysql-handlers roles/mysql/handlers/main.yml
cp mysql-root-cnf-template roles/mysql/templates/root-my.cnf.j2
cp mysql-cnf-template roles/mysql/templates/my.cnf.j2

# Copy the MariaDB role files
cp mariadb-install roles/mariadb/tasks/install.yml
cp mariadb-configure roles/mariadb/tasks/configure.yml
cp mariadb-defaults roles/mariadb/defaults/main.yml
cp mariadb-debian-vars roles/mariadb/vars/debian.yml
cp mariadb-redhat-vars roles/mariadb/vars/redhat.yml
cp mariadb-handlers roles/mariadb/handlers/main.yml
cp mariadb-root-cnf-template roles/mariadb/templates/root-my.cnf.j2
cp mariadb-cnf-template roles/mariadb/templates/mariadb.cnf.j2
cp mariadb-repo-template roles/mariadb/templates/mariadb.repo.j2

# Copy the PostgreSQL role files
cp postgresql-install roles/postgresql/tasks/install.yml
cp postgresql-configure roles/postgresql/tasks/configure.yml
cp postgresql-defaults roles/postgresql/defaults/main.yml
cp postgresql-debian-vars roles/postgresql/vars/debian.yml
cp postgresql-redhat-vars roles/postgresql/vars/redhat.yml
cp postgresql-handlers roles/postgresql/handlers/main.yml
cp postgresql-conf-template roles/postgresql/templates/postgresql.conf.j2
cp postgresql-hba-template roles/postgresql/templates/pg_hba.conf.j2

# Copy the Redis role files
cp redis-install roles/redis/tasks/install.yml
cp redis-configure roles/redis/tasks/configure.yml
cp redis-defaults roles/redis/defaults/main.yml
cp redis-debian-vars roles/redis/vars/debian.yml
cp redis-redhat-vars roles/redis/vars/redhat.yml
cp redis-handlers roles/redis/handlers/main.yml
cp redis-conf-template roles/redis/templates/redis.conf.j2

# Copy the Webserver role files
cp webserver-install roles/webserver/tasks/install.yml
cp webserver-configure roles/webserver/tasks/configure.yml
cp webserver-nginx-install roles/webserver/tasks/nginx.yml
cp webserver-nginx-configure roles/webserver/tasks/nginx_configure.yml
cp webserver-apache-install roles/webserver/tasks/apache.yml
cp webserver-apache-configure roles/webserver/tasks/apache_configure.yml
cp webserver-defaults roles/webserver/defaults/main.yml
cp webserver-debian-vars roles/webserver/vars/debian.yml
cp webserver-redhat-vars roles/webserver/vars/redhat.yml
cp webserver-handlers roles/webserver/handlers/main.yml
cp nginx-laravel-template roles/webserver/templates/nginx/laravel.conf.j2
cp nginx-conf-template roles/webserver/templates/nginx/nginx.conf.j2
cp apache-laravel-template roles/webserver/templates/apache/laravel.conf.j2
cp apache-conf-template roles/webserver/templates/apache/apache2.conf.j2

# Copy main playbook files
cp site-yml site.yml
cp deploy-laravel-yml deploy-laravel.yml
cp laravel-maintenance-yml laravel-maintenance.yml
cp security-hardening-yml security-hardening.yml

# Copy configuration files
cp env-template templates/env.j2
cp 20auto-upgrades-template templates/20auto-upgrades.j2
cp nginx-security-headers-template templates/nginx-security-headers.j2

# Copy vars files
cp versions-yml vars/versions.yml
cp all-yml group_vars/all.yml

# Copy inventory file
cp inventory-hosts inventory/hosts.yml

# Copy documentation files
cp readme-md README.md
cp deployment-guide DEPLOYMENT_GUIDE.md

# Create GitHub Actions workflow
mkdir -p .github/workflows
echo 'name: Ansible Lint

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
          python-version: "3.10"
          
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install ansible ansible-lint
          
      - name: Lint Ansible Playbook
        run: |
          ansible-lint
' > .github/workflows/ansible-lint.yml

# Create .gitignore
echo '# Ansible specific files
*.retry
*.pyc
__pycache__/
.cache/

# Ansible Vault passwords
.vault_pass
.vault_pass.txt
*.vault

# Local inventory files with sensitive data
/inventory/local.yml

# Runtime and temporary files
*.log
*.tmp
*.swp
*~

# Editor and IDE files
.idea/
.vscode/
*.iml
.DS_Store

# Credentials and secrets
/group_vars/*/vault.yml
/host_vars/*/vault.yml
' > .gitignore

echo -e "${GREEN}Project structure organized successfully!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Review the generated files and adjust as needed"
echo "2. Update the inventory with your servers"
echo "3. Customize variables in group_vars/all.yml"
echo "4. Run ansible-lint to validate your playbook"
echo "5. Deploy with: ansible-playbook -i inventory/hosts.yml site.yml"
echo -e "${GREEN}Done!${NC}"