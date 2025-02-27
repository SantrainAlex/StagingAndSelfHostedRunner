#!/bin/bash

echo "🚀 Démarrage du déploiement en production..."

# Variables
CONTAINER_NAME="production-app"
IMAGE_NAME="react-app:production"
PORT=80

# Exécution des tests
echo "🧪 Exécution des tests..."
npm test || { echo "❌ Les tests ont échoué"; exit 1; }

# Construction de l'image Docker pour la production
echo "🏗️ Construction de l'image Docker pour la production..."
docker build -t $IMAGE_NAME -f docker/production/Dockerfile .

# Nettoyage des anciens conteneurs
echo "🧹 Nettoyage des anciens conteneurs de production..."
docker stop $CONTAINER_NAME >/dev/null 2>&1
docker rm $CONTAINER_NAME >/dev/null 2>&1

# Démarrage du nouveau conteneur
echo "🚀 Démarrage du conteneur de production..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:80 \
    -e NODE_ENV=production \
    $IMAGE_NAME

echo "✅ Application déployée avec succès en production"
echo "📱 L'application est accessible sur http://localhost:$PORT"
echo "📝 Logs du conteneur:"
docker logs $CONTAINER_NAME
