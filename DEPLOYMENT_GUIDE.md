# 🚀 Guide de Déploiement Production - DonM

## 📋 Prérequis

### Infrastructure requise
- **Serveur** : Ubuntu 20.04+ ou CentOS 8+
- **RAM** : Minimum 4GB, recommandé 8GB+
- **Stockage** : Minimum 50GB SSD
- **CPU** : Minimum 2 cœurs, recommandé 4+
- **Réseau** : Bande passante stable

### Logiciels requis
- **Docker** & **Docker Compose**
- **Nginx** (inclus dans Docker)
- **Domaine** avec configuration DNS
- **Certificat SSL/TLS**

## 🌐 Configuration du Domaine

### 1. Choisir un nom de domaine
Exemples pour DonM :
- `donm.ci` (recommandé pour la Côte d'Ivoire)
- `donm-africa.com`
- `livraison-donm.com`

### 2. Configuration DNS
Configurer les enregistrements DNS suivants :

```dns
# Enregistrement A
donm.ci.      IN    A    192.168.1.100

# Sous-domaines
api.donm.ci.   IN    A    192.168.1.100
grafana.donm.ci IN    A    192.168.1.100
prometheus.donm.ci IN A 192.168.1.100

# Enregistrement CNAME (optionnel)
www.donm.ci.   IN    CNAME donm.ci.
```

## 🐳 Déploiement avec Docker

### 1. Préparation du serveur

```bash
# Mettre à jour le système
sudo apt update && sudo apt upgrade -y

# Installer Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Installer Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Créer les répertoires nécessaires
sudo mkdir -p /opt/donm/{data,ssl,logs}
sudo chown -R $USER:$USER /opt/donm
```

### 2. Configuration SSL/TLS

```bash
# Générer des certificats auto-signés (développement)
cd /opt/donm/ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout donm.key \
  -out donm.crt \
  -subj "/C=CI/ST=Abidjan/L=Abidjan/O=DonM/CN=donm.ci"

# OU utiliser Let's Encrypt (production)
sudo apt install certbot
sudo certbot certonly --standalone -d donm.ci -d api.donm.ci -d grafana.donm.ci
```

### 3. Configuration des variables d'environnement

Créer le fichier `.env.production` :

```bash
# Base de données
POSTGRES_DB=donm_production
POSTGRES_USER=donm_user
POSTGRES_PASSWORD=VOTRE_MOT_DE_PASSE_SECURE
POSTGRES_HOST=postgres
POSTGRES_PORT=5432

# API
NODE_ENV=production
PORT=3000
JWT_SECRET=VOTRE_JWT_SECRET_TRES_SECURE
BASE_URL=https://donm.ci

# Redis
REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=VOTRE_REDIS_PASSWORD

# Mobile Money (configurer avec les vraies clés)
ORANGE_MONEY_API_URL=https://api.orange-money.ci
ORANGE_MONEY_API_KEY=VOTRE_CLE_ORANGE
ORANGE_MONEY_SECRET=VOTRE_SECRET_ORANGE

MTN_MONEY_API_URL=https://api.mtn.ci
MTN_MONEY_API_KEY=VOTRE_CLE_MTN
MTN_MONEY_SECRET=VOTRE_SECRET_MTN

# Monitoring
PROMETHEUS_RETENTION=30d
GRAFANA_ADMIN_PASSWORD=VOTRE_MOT_DE_PASSE_GRAFANA
```

### 4. Déploiement

```bash
# Cloner le projet
git clone <votre-repo> /opt/donm/app
cd /opt/donm/app

# Copier la configuration de production
cp .env.production .env

# Construire et démarrer les services
docker-compose -f docker/docker-compose.yml --env-file .env up -d

# Vérifier le statut
docker-compose ps
```

## 📱 Configuration Flutter pour Production

### 1. Build de l'application

```bash
# Aller dans le répertoire Flutter
cd /opt/donm/app

# Build pour production web
flutter build web --release --web-renderer canvaskit

# Copier les fichiers de production
cp -r build/web/* /opt/donm/data/web/
```

### 2. Configuration du fichier web/index.html

Le fichier `production/web/index.html` est déjà configuré avec :
- ✅ SEO optimisé
- ✅ Meta tags Open Graph
- ✅ Twitter Cards
- ✅ PWA manifest
- ✅ Critical CSS
- ✅ Lazy loading
- ✅ Service Worker

## 🔧 Configuration Nginx

Le fichier `docker/nginx/nginx-production.conf` inclut :

- ✅ **Reverse proxy** pour l'API
- ✅ **SSL/TLS** avec HTTP/2
- ✅ **Compression Gzip**
- ✅ **Cache statique**
- ✅ **Rate limiting**
- ✅ **Security headers**
- ✅ **WebSocket support**
- ✅ **Health checks**

## 📊 Configuration Monitoring

### Accès aux services

- **Application** : https://donm.ci
- **API** : https://api.donm.ci
- **Métriques** : https://api.donm.ci/metrics
- **Grafana** : https://grafana.donm.ci
- **Prometheus** : https://prometheus.donm.ci

### Alertes configurées

- ✅ Taux d'erreur > 1%
- ✅ Temps de réponse > 2s
- ✅ Utilisation mémoire > 90%
- ✅ Taux d'échec paiement > 30%
- ✅ Aucun utilisateur actif

## 🔍 Vérification du déploiement

### 1. Tests de santé

```bash
# Health check API
curl https://api.donm.ci/api/health

# Health check détaillé
curl https://api.donm.ci/health/detailed

# Vérifier les métriques
curl https://api.donm.ci/metrics
```

### 2. Tests fonctionnels

```bash
# Test d'inscription
curl -X POST https://api.donm.ci/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@donm.ci","password":"password123","role":"client"}'

# Test de création de commande
curl -X POST https://api.donm.ci/api/orders \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer VOTRE_TOKEN" \
  -d '{"pickup_address":"Abidjan, Cocody","delivery_address":"Abidjan, Plateau","distance":5.5}'
```

## 🔄 Maintenance et Mises à jour

### 1. Mise à jour de l'application

```bash
# Sauvegarder la base de données
docker-compose exec postgres pg_dump donm_production > backup_$(date +%Y%m%d_%H%M%S).sql

# Mettre à jour le code
cd /opt/donm/app
git pull origin main

# Rebuild les services
docker-compose build --no-cache
docker-compose up -d

# Vérifier le statut
docker-compose ps
```

### 2. Nettoyage automatique

```bash
# Ajouter au crontab pour le nettoyage
crontab -e

# Ajouter ces lignes :
# Nettoyer les anciennes données analytics (chaque dimanche à 2h)
0 2 * * 0 /opt/donm/app/api/node scripts/cleanup-analytics.js

# Sauvegarder la base de données (chaque jour à 3h)
0 3 * * * /opt/donm/scripts/backup-db.sh

# Redémarrer les services si nécessaire (chaque jour à 4h)
0 4 * * * cd /opt/donm && docker-compose restart
```

## 🛡️ Sécurité

### 1. Configuration firewall

```bash
# Configurer UFW
sudo ufw enable
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw deny 3000/tcp  # Cacher l'API directement
```

### 2. Monitoring de sécurité

```bash
# Surveiller les logs
docker-compose logs -f api | grep -i error

# Surveiller les connexions
sudo netstat -tulpn | grep :80
sudo netstat -tulpn | grep :443
```

## 📈 Performance et Scaling

### 1. Optimisation de la base de données

```bash
# Exécuter les optimisations PostgreSQL
docker-compose exec postgres psql -U donm_user -d donm_production -f /docker/donm_optimization_queries.sql
```

### 2. Configuration du cache Redis

```bash
# Vérifier l'utilisation du cache
docker-compose exec redis redis-cli info stats

# Vider le cache si nécessaire
docker-compose exec redis redis-cli flushall
```

### 3. Scaling horizontal

Pour ajouter des instances API :

```yaml
# Dans docker-compose.yml
services:
  api:
    image: donm-api:latest
    deploy:
      replicas: 3
    environment:
      - NODE_ENV=production
```

## 🚨 Gestion des Incidents

### 1. Procédure en cas d'erreur

1. **Identifier le problème** via Grafana
2. **Vérifier les logs** : `docker-compose logs api`
3. **Redémarrer le service** : `docker-compose restart api`
4. **Vérifier l'état** : `curl https://api.donm.ci/health`
5. **Notifier les utilisateurs** si nécessaire

### 2. Rollback

```bash
# Revenir à la version précédente
cd /opt/donm/app
git checkout <previous-tag>
docker-compose build
docker-compose up -d
```

## 📞 Support et Contact

### Équipe de support
- **Email** : support@donm.ci
- **Téléphone** : +225 00 00 00 00
- **Documentation** : https://docs.donm.ci

### Heures de disponibilité
- **Lundi - Vendredi** : 8h - 18h
- **Samedi** : 9h - 15h
- **Dimanche** : Fermé (urgence uniquement)

---

## 🎉 Déploiement Terminé !

Une fois ces étapes complétées, votre application DonM sera accessible :

🌐 **URL Principale** : `https://donm.ci`
📱 **Application Mobile** : `https://donm.ci` (responsive)
🔌 **API** : `https://api.donm.ci`
📊 **Monitoring** : `https://grafana.donm.ci`
📈 **Métriques** : `https://api.donm.ci/metrics`

L'application est maintenant **production-ready** avec monitoring complet, analytics avancés, et haute performance ! 🚀
