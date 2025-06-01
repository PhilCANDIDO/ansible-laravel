# 🚀 Guide d'Utilisation - Laravel 11 Ansible Deployment

Ce guide vous explique comment utiliser les playbooks Ansible pour installer les prérequis Laravel 11.

## 📋 Prérequis

- **Ansible 2.12+** installé sur votre machine de contrôle
- **SSH access** aux serveurs cibles
- **Privilèges sudo** sur les serveurs cibles
- **Python 3** sur les serveurs cibles

## 🎯 Deux Options d'Installation

### Option 1: Installation Rapide (Recommandée pour débuter)

Pour une installation rapide avec des paramètres par défaut :

```bash
# 1. Cloner le repository
git clone https://github.com/PhilCANDIDO/ansible-laravel.git
cd ansible-laravel

# 2. Éditer l'inventaire avec vos serveurs
cp inventory/hosts_sample.yml inventory/hosts.yml
nano inventory/hosts.yml  # Configurer vos IPs et credentials

# 3. Lancer l'installation rapide
ansible-playbook -i inventory/hosts.yml quick-install.yml
```

### Option 2: Installation Complète (Recommandée pour production)

Pour une installation complète avec tous les rôles :

```bash
# 1. Configurer les variables globales
nano group_vars/all.yml  # Personnaliser selon vos besoins

# 2. Lancer l'installation complète
ansible-playbook -i inventory/hosts.yml site.yml
```

## ⚙️ Configuration de l'Inventaire

### Configuration Minimale

```yaml
# inventory/hosts.yml
all:
  children:
    webservers:
      hosts:
        my-server:
          ansible_host: 192.168.1.100
          ansible_user: ubuntu
          ansible_ssh_private_key_file: ~/.ssh/id_rsa
```

### Configuration Avancée

```yaml
# inventory/hosts.yml
all:
  children:
    production:
      hosts:
        prod-server:
          ansible_host: 192.168.1.100
          
          # Configuration Laravel
          webserver_server_name: "myapp.com"
          webserver_laravel_root: "/var/www/myapp"
          webserver_enable_ssl: true
          
          # Optimisations production
          php_memory_limit: "512M"
          enable_redis: true
          
  vars:
    # Variables globales
    laravel_version: "11"
    db_engine: "mysql"
    webserver_type: "nginx"
```

## 🎛️ Personnalisation via Variables

### Variables Principales

| Variable | Description | Valeurs | Défaut |
|----------|-------------|---------|---------|
| `laravel_version` | Version de Laravel | `"11"`, `"10"` | `"11"` |
| `db_engine` | Moteur de base de données | `mysql`, `mariadb`, `postgresql` | `mysql` |
| `webserver_type` | Serveur web | `nginx`, `apache` | `nginx` |
| `enable_redis` | Activer Redis | `true`, `false` | `false` |

### Variables PHP

```yaml
# Dans group_vars/all.yml ou host_vars/
php_memory_limit: "256M"
php_max_execution_time: 120
php_timezone: "Europe/Paris"
```

### Variables Base de Données

```yaml
# MySQL
mysql_root_password: "votre_mot_de_passe_root"
mysql_db_name: "laravel"
mysql_db_user: "laravel"
mysql_db_password: "votre_mot_de_passe_app"

# PostgreSQL
postgresql_admin_password: "votre_mot_de_passe_admin"
postgresql_db_name: "laravel"
postgresql_db_user: "laravel"
postgresql_db_password: "votre_mot_de_passe_app"
```

### Variables Serveur Web

```yaml
webserver_server_name: "monapp.com"
webserver_laravel_root: "/var/www/monapp"
webserver_enable_ssl: true
webserver_ssl_certificate: "/path/to/cert.crt"
webserver_ssl_certificate_key: "/path/to/private.key"
```

## 🏷️ Utilisation des Tags

Installer seulement certains composants :

```bash
# Installer seulement PHP et Composer
ansible-playbook -i inventory/hosts.yml site.yml --tags "php,composer"

# Installer seulement la base de données
ansible-playbook -i inventory/hosts.yml site.yml --tags "database"

# Installer seulement le serveur web
ansible-playbook -i inventory/hosts.yml site.yml --tags "webserver"

# Installer tout sauf Redis
ansible-playbook -i inventory/hosts.yml site.yml --skip-tags "redis"
```

## 🎯 Exemples d'Utilisation

### 1. Serveur de Développement Local

```bash
# Configuration pour développement avec SQLite
ansible-playbook -i inventory/hosts.yml quick-install.yml \
  -e "db_engine=mysql" \
  -e "enable_redis=false" \
  -e "webserver_server_name=laravel.local"
```

### 2. Serveur de Staging

```bash
# Configuration staging avec MySQL et Redis
ansible-playbook -i inventory/hosts.yml site.yml \
  -e "db_engine=mysql" \
  -e "enable_redis=true" \
  -e "php_memory_limit=256M"
```

### 3. Serveur de Production

```bash
# Configuration production complète
ansible-playbook -i inventory/hosts.yml site.yml \
  -e "db_engine=postgresql" \
  -e "enable_redis=true" \
  -e "webserver_enable_ssl=true" \
  -e "php_memory_limit=512M"
```

## 🔐 Gestion des Mots de Passe

### Utilisation d'Ansible Vault (Recommandé)

```bash
# 1. Créer un fichier de mots de passe
ansible-vault create group_vars/all/vault.yml

# 2. Ajouter vos mots de passe
vault_mysql_root_password: "super_secure_password"
vault_mysql_db_password: "app_secure_password"

# 3. Référencer dans group_vars/all.yml
mysql_root_password: "{{ vault_mysql_root_password }}"
mysql_db_password: "{{ vault_mysql_db_password }}"

# 4. Lancer avec le vault
ansible-playbook -i inventory/hosts.yml site.yml --ask-vault-pass
```

### Variables d'Environnement

```bash
# Passer les mots de passe via l'environnement
export MYSQL_ROOT_PASSWORD="secure_password"
export MYSQL_DB_PASSWORD="app_password"

ansible-playbook -i inventory/hosts.yml site.yml \
  -e "mysql_root_password=$MYSQL_ROOT_PASSWORD" \
  -e "mysql_db_password=$MYSQL_DB_PASSWORD"
```

## 🧪 Tests et Vérification

### Vérifier la Configuration

```bash
# Test de connectivité
ansible all -i inventory/hosts.yml -m ping

# Vérifier les variables
ansible-playbook -i inventory/hosts.yml site.yml --check --diff

# Mode dry-run
ansible-playbook -i inventory/hosts.yml site.yml --check
```

### Après Installation

1. **Tester PHP** : `http://votre-serveur/info.php`
2. **Vérifier les services** :
   ```bash
   sudo systemctl status nginx php8.2-fpm mysql
   ```
3. **Tester la base de données** :
   ```bash
   mysql -u laravel -p laravel
   ```

## 📊 Déploiement d'Application Laravel

Après l'installation des prérequis :

```bash
# 1. Déployer l'application
ansible-playbook -i inventory/hosts.yml deploy-laravel.yml \
  -e "laravel_deploy_repo=https://github.com/votre-user/votre-app.git"

# 2. Maintenance Laravel
ansible-playbook -i inventory/hosts.yml laravel-maintenance.yml \
  -e "maintenance_task=migrate"
```

## 🛠️ Maintenance

### Mise à Jour du Système

```bash
# Mettre à jour seulement les paquets système
ansible-playbook -i inventory/hosts.yml site.yml --tags "common"
```

### Reconfiguration

```bash
# Reconfigurer seulement PHP
ansible-playbook -i inventory/hosts.yml site.yml --tags "php" --skip-tags "install"

# Reconfigurer le serveur web
ansible-playbook -i inventory/hosts.yml site.yml --tags "webserver" --skip-tags "install"
```

## 🚨 Dépannage

### Problèmes Courants

1. **Erreur de permissions** :
   ```bash
   # Corriger les permissions Laravel
   ansible all -i inventory/hosts.yml -m file \
     -a "path=/var/www/laravel/storage recurse=yes owner=www-data group=www-data mode=0775" \
     --become
   ```

2. **Service non démarré** :
   ```bash
   # Redémarrer les services
   ansible all -i inventory/hosts.yml -m service \
     -a "name=nginx state=restarted" --become
   ```

3. **Configuration PHP** :
   ```bash
   # Vérifier la configuration PHP
   ansible all -i inventory/hosts.yml -m command \
     -a "php -m" --become
   ```

### Logs à Vérifier

```bash
# Logs Nginx
sudo tail -f /var/log/nginx/error.log

# Logs PHP-FPM
sudo tail -f /var/log/php8.2-fpm.log

# Logs MySQL
sudo tail -f /var/log/mysql/error.log
```

## 📚 Ressources

- [Documentation Laravel](https://laravel.com/docs/11.x)
- [Documentation Ansible](https://docs.ansible.com/)
- [Guide de Sécurité](./security-hardening.yml)
- [Repository GitHub](https://github.com/PhilCANDIDO/ansible-laravel)