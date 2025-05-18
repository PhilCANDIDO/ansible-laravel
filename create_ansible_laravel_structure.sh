#!/bin/bash
# Script to create the ansible-laravel project structure
# Author: Claude
# Date: May 18, 2025

set -e  # Exit immediately if a command exits with a non-zero status

# Define colors for better output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Creating ansible-laravel project structure...${NC}"

# Create the base directory if it doesn't exist
# mkdir -p ansible-laravel
# cd ansible-laravel

# Create main directories
mkdir -p inventory group_vars vars roles

# Create the roles subdirectories
ROLES=("php" "composer" "nodejs" "mysql" "mariadb" "postgresql" "redis" "webserver")
for role in "${ROLES[@]}"; do
    mkdir -p roles/$role/{tasks,defaults,vars,handlers,templates}
    
    # Create basic files for each role
    echo "---
# $role role main tasks file
- name: Include installation tasks
  include_tasks: install.yml

- name: Include configuration tasks
  include_tasks: configure.yml
  when: configure_$role | default(true) | bool" > roles/$role/tasks/main.yml
    
    echo "---
# $role installation tasks" > roles/$role/tasks/install.yml
    
    echo "---
# $role configuration tasks" > roles/$role/tasks/configure.yml
    
    echo "---
# Default variables for $role role" > roles/$role/defaults/main.yml
    
    echo "---
# Internal variables for $role role" > roles/$role/vars/main.yml
    
    echo "---
# Handlers for $role role" > roles/$role/handlers/main.yml
done

# Create webserver-specific directories for templates
mkdir -p roles/webserver/templates/{nginx,apache}
touch roles/webserver/templates/nginx/laravel.conf.j2
touch roles/webserver/templates/apache/laravel.conf.j2

# Add specific task files for webserver role
echo "---
# Nginx installation tasks" > roles/webserver/tasks/nginx.yml
echo "---
# Apache installation tasks" > roles/webserver/tasks/apache.yml

# Create base configuration files
echo "---
# Main playbook for Laravel 11 environment setup

- name: Deploy Laravel 11 Environment
  hosts: all
  become: true
  vars_files:
    - vars/versions.yml
  
  pre_tasks:
    - name: Update package cache
      ansible.builtin.package:
        update_cache: true
      when: update_cache | default(true) | bool
  
  roles:
    - role: php
      tags: [php]
    
    - role: composer
      tags: [composer]
    
    - role: nodejs
      tags: [nodejs]
    
    - role: mysql
      tags: [database, mysql]
      when: db_engine == 'mysql'
    
    - role: mariadb
      tags: [database, mariadb]
      when: db_engine == 'mariadb'
    
    - role: postgresql
      tags: [database, postgresql]
      when: db_engine == 'postgresql'
    
    - role: redis
      tags: [redis]
      when: enable_redis | default(false) | bool
    
    - role: webserver
      tags: [webserver]" > site.yml

# Create inventory file
echo "---
# Inventory file

all:
  children:
    webservers:
      hosts:
        webserver1:
          ansible_host: 192.168.1.10
    
    # Example for multiple environments
    staging:
      hosts:
        staging_server:
          ansible_host: 192.168.1.20
    
    production:
      hosts:
        production_server:
          ansible_host: 192.168.1.30" > inventory/hosts.yml

# Create group_vars files
echo "---
# Variables for all hosts

# PHP configuration
php_version: \"{{ laravel_versions[laravel_version].php.version }}\"
php_extensions: \"{{ laravel_versions[laravel_version].php.extensions }}\"

# Composer configuration
composer_version: \"{{ laravel_versions[laravel_version].composer.version }}\"

# Node.js configuration
nodejs_version: \"{{ laravel_versions[laravel_version].nodejs.version }}\"

# Database configuration
db_engine: mysql  # Options: mysql, mariadb, postgresql

# Redis configuration
enable_redis: false

# Webserver configuration
webserver_type: nginx  # Options: nginx, apache

# Laravel version
laravel_version: \"11\"" > group_vars/all.yml

# Create versions.yml
echo "---
# Laravel version requirements mapping
# This file maps Laravel versions to their required dependencies

laravel_versions:
  \"11\":
    php:
      version: \"8.2\"  # Laravel 11 requires PHP 8.2+
      extensions:
        - bcmath
        - ctype
        - curl
        - dom
        - fileinfo
        - filter
        - json
        - mbstring
        - openssl
        - pcre
        - pdo
        - pdo_mysql
        - session
        - tokenizer
        - xml
        - zip
    composer:
      version: \"latest\"  # Always use the latest Composer version
    nodejs:
      version: \"20.x\"    # Using LTS version for Node.js
    databases:
      mysql:
        version: \"8.0\"
      mariadb:
        version: \"10.11\"  # MariaDB 10.11 LTS
      postgresql:
        version: \"15\"
    redis:
      version: \"7.0\"  # Latest stable Redis version" > vars/versions.yml

# Create README.md
echo "# Ansible Laravel 11 Deployment

This Ansible project automates the deployment of all dependencies required to run a Laravel 11 environment.

## Project Structure

\`\`\`
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
\`\`\`

## Requirements

- Ansible 2.12 or higher
- SSH access to target servers
- Sudo privileges on target servers

## Supported Distributions

- RHEL-like 8 & 9 (AlmaLinux, RockyLinux, OracleLinux)
- Debian-like 11 & 12
- Ubuntu 20.04, 22.04, 24.04

## Variables

The main configuration variables are set in \`group_vars/all.yml\`:

- \`laravel_version\`: Laravel version to deploy (default: 11)
- \`db_engine\`: Database engine to use (options: mysql, mariadb, postgresql)
- \`enable_redis\`: Whether to install Redis (default: false)
- \`webserver_type\`: Web server to install (options: nginx, apache)

## Usage

1. Update the inventory file with your server information:
   
   \`\`\`yaml
   # inventory/hosts.yml
   all:
     children:
       webservers:
         hosts:
           webserver1:
             ansible_host: 192.168.1.10
   \`\`\`

2. Customize the variables in \`group_vars/all.yml\` if needed.

3. Run the playbook:
   
   \`\`\`bash
   ansible-playbook -i inventory/hosts.yml site.yml
   \`\`\`

4. To run with specific tags:
   
   \`\`\`bash
   ansible-playbook -i inventory/hosts.yml site.yml --tags php,webserver
   \`\`\`

## Customizing the Stack

### Database Engine

Set the \`db_engine\` variable to choose your database:

\`\`\`yaml
# In group_vars/all.yml or via command line
db_engine: postgresql  # Options: mysql, mariadb, postgresql
\`\`\`

### Redis

Enable Redis installation:

\`\`\`yaml
# In group_vars/all.yml or via command line
enable_redis: true
\`\`\`

### Web Server

Choose between NGINX and Apache:

\`\`\`yaml
# In group_vars/all.yml or via command line
webserver_type: apache  # Options: nginx, apache
\`\`\`

## GitHub Actions Workflow Example

Here's a basic GitHub Actions workflow example for CI:

\`\`\`yaml
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
\`\`\`

## License

MIT License
" > README.md

# Create a GitHub Actions workflow file
mkdir -p .github/workflows
echo "name: Ansible Lint

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
" > .github/workflows/ansible-lint.yml

# Make script executable
chmod +x roles/*/tasks/*.yml

echo -e "${GREEN}Project structure created successfully!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Implement task files for each role"
echo "2. Update the inventory with your servers"
echo "3. Customize variables as needed"
echo "4. Run ansible-lint to validate your playbook"
echo -e "${GREEN}Done!${NC}"

cd ..