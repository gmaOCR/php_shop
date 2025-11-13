# Dockerfile pour Nginx (serveur web pour Symfony)
FROM nginx:alpine

# Copier la configuration Nginx
COPY nginx/nginx.conf /etc/nginx/conf.d/default.conf

# Créer les répertoires nécessaires
RUN mkdir -p /var/www/html/public /var/log/nginx /var/cache/nginx \
    && chown -R nginx:nginx /var/log/nginx /var/cache/nginx

# Exposer le port 80
EXPOSE 80

# Commande par défaut
CMD ["nginx", "-g", "daemon off;"]