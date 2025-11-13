# Dockerfile pour le frontend React (Production)
FROM node:20-alpine AS build

# Définir le répertoire de travail
WORKDIR /app

# Copier les fichiers de configuration
COPY frontend/package.json frontend/package-lock.json ./

# Installer les dépendances
RUN npm ci --only=production

# Copier le code source
COPY frontend/ .

# Build l'application
RUN npm run build

# Étape de production avec Nginx
FROM nginx:alpine

# Copier la configuration Nginx personnalisée
COPY --from=build /app/dist /usr/share/nginx/html

# Copier la configuration Nginx
COPY frontend/nginx.conf /etc/nginx/conf.d/default.conf

# Exposer le port 80
EXPOSE 80

# Commande par défaut
CMD ["nginx", "-g", "daemon off;"]