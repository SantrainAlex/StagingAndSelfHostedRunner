#!/bin/bash

# Activation du mode debug pour voir les commandes exécutées
set -x

echo "🚀 Démarrage du déploiement en staging..."

# Variables
CONTAINER_NAME="staging-app"
IMAGE_NAME="react-app:staging"
PORT=3001

# Couleurs pour les messages
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Fonction pour le nettoyage
cleanup() {
    local exit_after=$1
    echo -e "${RED}❌ Nettoyage des conteneurs...${NC}"
    if docker ps -a | grep -q $CONTAINER_NAME; then
        echo "Arrêt du conteneur $CONTAINER_NAME..."
        docker stop $CONTAINER_NAME >/dev/null 2>&1 || true
        echo "Suppression du conteneur $CONTAINER_NAME..."
        docker rm $CONTAINER_NAME >/dev/null 2>&1 || true
    else
        echo "Aucun conteneur $CONTAINER_NAME trouvé à nettoyer."
    fi
    
    if [ "$exit_after" = "true" ]; then
        exit 1
    fi
}

# Configuration du trap pour capturer les erreurs
trap 'cleanup true' ERR

# Vérification de Docker
echo "🔍 Vérification de Docker..."
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker n'est pas disponible ou n'est pas démarré${NC}"
    exit 1
fi

# Exécution des tests
echo "🧪 Exécution des tests..."
npm test || { echo -e "${RED}❌ Les tests ont échoué${NC}"; exit 1; }

# Nettoyage initial des anciens conteneurs
echo "🧹 Nettoyage initial des anciens conteneurs..."
cleanup false

# Construction de l'image Docker pour le staging
echo "🏗️ Construction de l'image Docker pour le staging..."
docker buildx build --platform linux/amd64 --load -t $IMAGE_NAME -f docker/staging/Dockerfile . || { 
    echo -e "${RED}❌ Échec de la construction de l'image${NC}"
    docker buildx build --platform linux/amd64 --load -t $IMAGE_NAME -f docker/staging/Dockerfile . --no-cache
    cleanup true
}

# Vérification que l'image existe
echo "🔍 Vérification de l'image..."
if ! docker image inspect $IMAGE_NAME >/dev/null 2>&1; then
    echo -e "${RED}❌ L'image $IMAGE_NAME n'a pas été créée correctement${NC}"
    cleanup true
fi

# Démarrage du nouveau conteneur
echo "🚀 Démarrage du conteneur de staging..."
if ! docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:80 \
    -e NODE_ENV=staging \
    $IMAGE_NAME; then
    echo -e "${RED}❌ Échec du démarrage du conteneur${NC}"
    docker logs $CONTAINER_NAME || true
    cleanup true
fi

# Vérification que le conteneur est bien démarré
echo "🔍 Vérification du conteneur..."
sleep 5
if docker ps | grep -q $CONTAINER_NAME; then
    echo -e "${GREEN}✅ Application déployée avec succès en staging${NC}"
    echo -e "${GREEN}📱 L'application est accessible sur http://localhost:$PORT${NC}"
    
    # Affichage des logs du conteneur
    echo "📝 Logs du conteneur:"
    docker logs $CONTAINER_NAME
else
    echo -e "${RED}❌ Le conteneur n'est pas en cours d'exécution${NC}"
    echo "Derniers logs avant l'échec:"
    docker logs $CONTAINER_NAME || true
    cleanup true
fi

# Désactivation du mode debug
set +x
