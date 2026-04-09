# DonM API - Documentation

## Overview

L'API DonM est une application Node.js/Express qui sert de backend pour l'application mobile DonM de livraison en Côte d'Ivoire.

## Fonctionnalités

- **Authentification JWT** : Sécurisation des endpoints avec tokens JWT
- **Gestion des utilisateurs** : Clients, vendeurs, livreurs
- **Gestion des produits** : CRUD pour les produits des vendeurs
- **Gestion des commandes** : Création, suivi, mise à jour des statuts
- **Système de paiements** : Mobile Money, espèces, carte bancaire
- **Notifications en temps réel** : Socket.IO pour les notifications instantanées
- **Base de données PostgreSQL** : Persistance des données

## Architecture

```
donm/
|-- api/
|   |-- server.js              # Serveur principal
|   |-- package.json           # Dépendances
|   |-- .env                   # Variables d'environnement
|   |-- routes/                # Routes API
|   |   |-- auth.js           # Authentification
|   |   |-- payments.js       # Paiements
|   |   |-- notifications.js   # Notifications
|   |-- middleware/            # Middleware
|   |   |-- auth.js           # Authentification JWT
|   |-- docker/                # Configuration Docker
|   |   |-- Dockerfile
|   |   |-- docker-compose.yml
|   |   |-- nginx/
|   |       |-- nginx.conf
|   |-- deploy.sh              # Script de déploiement
|-- lib/                       # Application Flutter
|   |-- services/
|   |   |-- api_service.dart   # Service API Flutter
|   |-- pages/
|   |   |-- payment_page.dart  # Page de paiement
|-- donm_database_simple.sql   # Script SQL PostgreSQL
```

## Installation

### Prérequis

- Node.js 18+
- PostgreSQL 12+
- npm ou yarn

### Étapes

1. **Cloner le repository**
   ```bash
   git clone <repository-url>
   cd donm/api
   ```

2. **Installer les dépendances**
   ```bash
   npm install
   ```

3. **Configurer la base de données**
   ```bash
   # Créer la base de données PostgreSQL
   createdb donm_db
   
   # Exécuter le script SQL
   psql -d donm_db -f ../donm_database_simple.sql
   ```

4. **Configurer les variables d'environnement**
   ```bash
   cp .env.example .env
   # Éditer .env avec vos configurations
   ```

5. **Démarrer l'API**
   ```bash
   npm start
   ```

L'API sera disponible sur `http://localhost:3000`

## Endpoints API

### Authentification

#### Inscription
```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "jean_kouadio",
  "email": "jean.kouadio@email.com",
  "phone": "+2250770000000",
  "password": "password123",
  "first_name": "Jean",
  "last_name": "Kouadio",
  "role": "client"
}
```

#### Connexion
```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "jean.kouadio@email.com",
  "password": "password123"
}
```

#### Vérification du token
```http
GET /api/auth/verify
Authorization: Bearer <token>
```

### Utilisateurs

#### Lister les utilisateurs
```http
GET /api/users?role=client
Authorization: Bearer <token>
```

#### Créer un utilisateur
```http
POST /api/users
Authorization: Bearer <token>
Content-Type: application/json

{
  "username": "vendeur1",
  "email": "vendeur1@email.com",
  "phone": "+2250770101010",
  "password_hash": "hashed_password",
  "first_name": "Marie",
  "last_name": "Konan",
  "role": "vendor",
  "shop_name": "Boutique Marie"
}
```

### Produits

#### Lister les produits
```http
GET /api/products?category=Plats%20chauds&available=true
Authorization: Bearer <token>
```

#### Créer un produit (vendeur uniquement)
```http
POST /api/products
Authorization: Bearer <token>
Content-Type: application/json

{
  "vendor_id": "uuid-vendeur",
  "name": "Attiéké et poisson fumé",
  "description": "Plat traditionnel ivoirien",
  "price": 2500.00,
  "category": "Plats chauds",
  "images": ["attieke.jpg"],
  "is_available": true
}
```

#### Mettre à jour un produit
```http
PUT /api/products/<product-id>
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "Attiéké et poisson fumé",
  "price": 2600.00,
  "is_available": false
}
```

### Commandes

#### Lister les commandes
```http
GET /api/orders?client_id=uuid-client&status=pending
Authorization: Bearer <token>
```

#### Créer une commande (client uniquement)
```http
POST /api/orders
Authorization: Bearer <token>
Content-Type: application/json

{
  "client_id": "uuid-client",
  "pickup_address": "Abidjan, Cocody, Boutique Marie",
  "delivery_address": "Abidjan, Yopougon, Zone 1",
  "distance": 5.5,
  "base_price": 2000.00,
  "delivery_fee": 500.00,
  "total_amount": 2500.00,
  "pickup_instructions": "Sonner à la porte",
  "delivery_instructions": "Appeler avant livraison"
}
```

#### Mettre à jour le statut d'une commande
```http
PUT /api/orders/<order-id>/status
Authorization: Bearer <token>
Content-Type: application/json

{
  "status": "confirmed",
  "delivery_person_id": "uuid-livreur"
}
```

### Paiements

#### Créer un paiement
```http
POST /api/payments
Authorization: Bearer <token>
Content-Type: application/json

{
  "order_id": "uuid-order",
  "amount": 2500.00,
  "method": "mobile_money",
  "transaction_id": "MM-123456789"
}
```

#### Payer avec Mobile Money
```http
POST /api/payments/mobile-money
Authorization: Bearer <token>
Content-Type: application/json

{
  "order_id": "uuid-order",
  "phone_number": "+2250770000000",
  "operator": "orange",
  "amount": 2500.00
}
```

#### Récupérer les paiements d'une commande
```http
GET /api/payments/order/<order-id>
Authorization: Bearer <token>
```

### Notifications

#### Créer une notification
```http
POST /api/notifications
Authorization: Bearer <token>
Content-Type: application/json

{
  "user_id": "uuid-user",
  "title": "Nouvelle commande",
  "message": "Vous avez reçu une nouvelle commande",
  "type": "order_created",
  "data": {
    "order_id": "uuid-order",
    "tracking_code": "TRK-12345"
  }
}
```

#### Lister les notifications d'un utilisateur
```http
GET /api/notifications/user/<user-id>?limit=20&unread_only=true
Authorization: Bearer <token>
```

#### Marquer une notification comme lue
```http
PUT /api/notifications/<notification-id>/read
Authorization: Bearer <token>
```

### Livreurs disponibles

#### Lister les livreurs disponibles
```http
GET /api/delivery-persons/available
Authorization: Bearer <token>
```

### Health Check

#### Vérifier la santé de l'API
```http
GET /api/health
```

## Socket.IO - Notifications en temps réel

### Événements

#### Connexion client
```javascript
const socket = io('http://localhost:3000');

// Rejoindre la room utilisateur
socket.emit('join_user_room', 'user-uuid');

// Rejoindre la room commande
socket.emit('join_order_room', 'order-uuid');

// Écouter les notifications
socket.on('notification', (data) => {
  console.log('Nouvelle notification:', data);
});
```

### Événements serveur

- `notification` : Nouvelle notification reçue
- `order_status_update` : Mise à jour du statut d'une commande
- `payment_status_change` : Changement de statut de paiement

## Déploiement

### Docker

#### Construire et déployer
```bash
# Développement
./deploy.sh dev

# Staging
./deploy.sh staging

# Production
./deploy.sh production
```

#### Docker Compose
```bash
docker-compose -f docker/docker-compose.yml up -d
```

### Variables d'environnement

```env
# Base de données
DB_HOST=localhost
DB_PORT=5432
DB_NAME=donm_db
DB_USER=postgres
DB_PASSWORD=votre_mot_de_passe

# Serveur
PORT=3000
NODE_ENV=production
JWT_SECRET=votre_secret_jwt

# CORS
CORS_ORIGIN=*
```

## Sécurité

### JWT Tokens

- Les tokens expirent après 7 jours
- Les routes protégées nécessitent un token valide
- Les tokens sont invalidés lors de la déconnexion

### Rôles et Permissions

- **client** : Peut créer des commandes, voir ses commandes
- **vendor** : Peut gérer ses produits, voir les commandes
- **delivery** : Peut voir les commandes assignées, mettre à jour les statuts

### Rate Limiting

- API générale : 10 requêtes/seconde
- Authentification : 5 requêtes/seconde

## Monitoring

### Health Checks

- API : `/api/health`
- Base de données : `pg_isready`
- Redis : `redis-cli ping`

### Logs

Les logs sont disponibles dans :
- Console de l'application
- Fichiers de logs Nginx
- Docker logs : `docker-compose logs -f`

## Erreurs communs

### 401 Unauthorized
- Token JWT manquant ou invalide
- Solution : Se connecter et obtenir un nouveau token

### 403 Forbidden
- Permissions insuffisantes pour l'action
- Solution : Vérifier le rôle de l'utilisateur

### 404 Not Found
- Ressource non trouvée
- Solution : Vérifier l'ID et que la ressource existe

### 500 Internal Server Error
- Erreur serveur
- Solution : Consulter les logs pour plus de détails

## Support

Pour toute question ou problème, contactez l'équipe de développement DonM.

---

**Version** : 1.0.0  
**Dernière mise à jour** : 2026-04-08
