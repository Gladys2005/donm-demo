# Étape 1: Utiliser une image Node.js légère
FROM node:18-alpine AS base

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de package
COPY package*.json ./

# Installer les dépendances
RUN npm ci --only=production && npm cache clean --force

# Étape 2: Construire l'application
FROM base AS builder

# Copier tous les fichiers source
COPY . .

# Créer un utilisateur non-root pour la sécurité
RUN addgroup -g 1001 -S nodejs
RUN adduser -S donm -u 1001

# Changer le propriétaire des fichiers
RUN chown -R donm:nodejs /app

# Étape 3: Image de production
FROM base AS production

# Copier les fichiers de l'étape builder
COPY --from=builder --chown=donm:nodejs /app .

# Exposer le port
EXPOSE 3000

# Basculer vers l'utilisateur non-root
USER donm

# Variables d'environnement par défaut
ENV NODE_ENV=production
ENV PORT=3000

# Vérification de santé
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Démarrer l'application
CMD ["node", "server.js"]
