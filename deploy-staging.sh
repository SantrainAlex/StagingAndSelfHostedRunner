#!/bin/bash

echo "🚀 Démarrage du déploiement en staging..."

# Variables
CONTAINER_NAME="staging-app"
IMAGE_NAME="react-app:staging"
PORT=3001

# Couleurs pour les messages
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Fonction pour le nettoyage en cas d'erreur
cleanup() {
    echo -e "${RED}❌ Erreur détectée. Nettoyage...${NC}"
    docker stop $CONTAINER_NAME >/dev/null 2>&1
    docker rm $CONTAINER_NAME >/dev/null 2>&1
    exit 1
}

# Configuration du trap pour capturer les erreurs
trap cleanup ERR

# Exécution des tests
echo "🧪 Exécution des tests..."
npm test || { echo -e "${RED}❌ Les tests ont échoué${NC}"; exit 1; }

# Construction de l'image Docker pour le staging
echo "🏗️ Construction de l'image Docker pour le staging..."
docker buildx build --platform linux/amd64 --load -t $IMAGE_NAME -f docker/staging/Dockerfile . || { echo -e "${RED}❌ Échec de la construction de l'image${NC}"; exit 1; }

# Vérification que l'image existe
if ! docker image inspect $IMAGE_NAME >/dev/null 2>&1; then
    echo -e "${RED}❌ L'image $IMAGE_NAME n'a pas été créée correctement${NC}"
    exit 1
fi

# Nettoyage des anciens conteneurs
echo "🧹 Nettoyage des anciens conteneurs de staging..."
docker stop $CONTAINER_NAME >/dev/null 2>&1
docker rm $CONTAINER_NAME >/dev/null 2>&1

# Démarrage du nouveau conteneur
echo "🚀 Démarrage du conteneur de staging..."
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:80 \
    -e NODE_ENV=staging \
    $IMAGE_NAME

# Vérification que le conteneur est bien démarré
if docker ps | grep -q $CONTAINER_NAME; then
    echo -e "${GREEN}✅ Application déployée avec succès en staging${NC}"
    echo -e "${GREEN}📱 L'application est accessible sur http://localhost:$PORT${NC}"
    
    # Attente pour s'assurer que le conteneur est bien démarré
    sleep 5
    
    # Affichage des logs du conteneur
    echo "📝 Logs du conteneur:"
    docker logs $CONTAINER_NAME
else
    echo -e "${RED}❌ Échec du démarrage du conteneur${NC}"
    cleanup
fi
