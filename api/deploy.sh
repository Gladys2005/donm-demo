#!/bin/bash

# Script de déploiement pour l'API DonM
# Usage: ./deploy.sh [environment]
# Environments: dev, staging, production

set -e  # Arrêter le script en cas d'erreur

# Couleurs pour les logs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonctions de log
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Variables
ENVIRONMENT=${1:-dev}
PROJECT_NAME="donm-api"
BACKUP_DIR="./backups"
LOG_FILE="./logs/deploy-$(date +%Y%m%d-%H%M%S).log"

# Créer les répertoires nécessaires
mkdir -p $BACKUP_DIR
mkdir -p logs

# Vérification de l'environnement
check_environment() {
    log_info "Vérification de l'environnement: $ENVIRONMENT"
    
    case $ENVIRONMENT in
        dev|staging|production)
            log_success "Environnement valide: $ENVIRONMENT"
            ;;
        *)
            log_error "Environnement invalide. Utilisez: dev, staging, ou production"
            exit 1
            ;;
    esac
}

# Sauvegarde de la base de données
backup_database() {
    if [ "$ENVIRONMENT" != "dev" ]; then
        log_info "Sauvegarde de la base de données..."
        
        BACKUP_FILE="$BACKUP_DIR/donm-db-backup-$(date +%Y%m%d-%H%M%S).sql"
        
        docker exec donm-db pg_dump -U donm_user donm_db > $BACKUP_FILE
        
        if [ $? -eq 0 ]; then
            log_success "Sauvegarde terminée: $BACKUP_FILE"
        else
            log_error "Échec de la sauvegarde"
            exit 1
        fi
    fi
}

# Construction de l'image Docker
build_image() {
    log_info "Construction de l'image Docker pour $ENVIRONMENT..."
    
    cd ..
    
    # Construire avec cache pour le développement
    if [ "$ENVIRONMENT" == "dev" ]; then
        docker build -f docker/Dockerfile -t $PROJECT_NAME:$ENVIRONMENT --build-arg NODE_ENV=development .
    else
        docker build -f docker/Dockerfile -t $PROJECT_NAME:$ENVIRONMENT --build-arg NODE_ENV=production --no-cache .
    fi
    
    if [ $? -eq 0 ]; then
        log_success "Image Docker construite avec succès"
    else
        log_error "Échec de la construction de l'image"
        exit 1
    fi
    
    cd docker
}

# Déploiement avec Docker Compose
deploy() {
    log_info "Déploiement de l'application..."
    
    # Variables d'environnement selon l'environnement
    export COMPOSE_PROJECT_NAME="donm-$ENVIRONMENT"
    
    case $ENVIRONMENT in
        dev)
            docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d
            ;;
        staging)
            docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d
            ;;
        production)
            docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
            ;;
    esac
    
    if [ $? -eq 0 ]; then
        log_success "Déploiement terminé"
    else
        log_error "Échec du déploiement"
        exit 1
    fi
}

# Vérification de la santé
health_check() {
    log_info "Vérification de la santé de l'application..."
    
    # Attendre que les services démarrent
    sleep 30
    
    # Vérifier l'API
    API_HEALTH=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/api/health)
    if [ "$API_HEALTH" == "200" ]; then
        log_success "API DonM est en bonne santé"
    else
        log_error "API DonM n'est pas en bonne santé (HTTP $API_HEALTH)"
        return 1
    fi
    
    # Vérifier la base de données
    DB_HEALTH=$(docker exec donm-db pg_isready -U donm_user -d donm_db)
    if [[ $DB_HEALTH == *"accepting connections"* ]]; then
        log_success "Base de données est en bonne santé"
    else
        log_error "Base de données n'est pas en bonne santé"
        return 1
    fi
    
    # Vérifier Redis (si présent)
    if docker ps | grep -q donm-redis; then
        REDIS_HEALTH=$(docker exec donm-redis redis-cli ping)
        if [ "$REDIS_HEALTH" == "PONG" ]; then
            log_success "Redis est en bonne santé"
        else
            log_error "Redis n'est pas en bonne santé"
            return 1
        fi
    fi
    
    return 0
}

# Nettoyage des anciennes images
cleanup() {
    log_info "Nettoyage des anciennes images Docker..."
    
    # Supprimer les images non utilisées
    docker image prune -f
    
    # Supprimer les anciennes versions (garder les 3 dernières)
    docker images $PROJECT_NAME --format "table {{.Repository}}:{{.Tag}}" | tail -n +2 | tail -n +4 | xargs -r docker rmi
    
    log_success "Nettoyage terminé"
}

# Rollback en cas d'échec
rollback() {
    log_warning "Rollback en cours..."
    
    # Arrêter les services
    docker-compose down
    
    # Restaurer la base de données si nécessaire
    if [ "$ENVIRONMENT" != "dev" ] && [ -f "$BACKUP_DIR/latest-backup.sql" ]; then
        log_info "Restauration de la base de données..."
        docker exec -i donm-db psql -U donm_user -d donm_db < $BACKUP_DIR/latest-backup.sql
    fi
    
    # Redémarrer avec la version précédente
    docker-compose up -d
    
    log_warning "Rollback terminé"
}

# Monitoring post-déploiement
monitoring() {
    log_info "Démarrage du monitoring..."
    
    # Afficher les logs des services
    docker-compose logs -f --tail=50 &
    
    # Afficher les statistiques des ressources
    watch -n 5 'docker stats --no-stream' &
    
    log_info "Monitoring activé. Utilisez Ctrl+C pour arrêter."
}

# Fonction principale
main() {
    log_info "Début du déploiement de DonM API pour l'environnement: $ENVIRONMENT"
    log_info "Date: $(date)"
    
    # Exécuter les étapes
    check_environment
    backup_database
    build_image
    
    # Déploiement avec rollback automatique en cas d'échec
    if ! deploy; then
        rollback
        exit 1
    fi
    
    # Vérification de la santé
    if ! health_check; then
        log_error "L'application n'est pas en bonne santé après le déploiement"
        rollback
        exit 1
    fi
    
    # Nettoyage
    cleanup
    
    log_success "Déploiement terminé avec succès !"
    
    # Monitoring optionnel
    if [ "$2" == "--monitor" ]; then
        monitoring
    fi
}

# Gestion des signaux
trap 'log_warning "Déploiement interrompu"; rollback; exit 1' INT TERM

# Exécuter la fonction principale
main "$@" 2>&1 | tee $LOG_FILE
