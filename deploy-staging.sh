#!/bin/bash

# Couleurs pour les messages
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "🚀 Démarrage du déploiement en staging..."

# Variables
CONTAINER_NAME="staging-app"
IMAGE_NAME="react-app:staging"
PORT=3001

# Fonction pour le nettoyage en cas d'erreur
cleanup() {
    echo -e "${RED}❌ Erreur détectée. Nettoyage...${NC}"
    # Arrêt des conteneurs de staging existants
    docker stop $CONTAINER_NAME >/dev/null 2>&1
    docker rm $CONTAINER_NAME >/dev/null 2>&1
    exit 1
}

# Capture des erreurs
trap cleanup ERR

# Exécution des tests
echo "🧪 Exécution des tests..."
npm test || { echo -e "${RED}❌ Les tests ont échoué${NC}"; exit 1; }

# Si les tests réussissent, on continue avec le déploiement
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Tests réussis${NC}"
    
    # Construction de l'image Docker pour le staging
    echo "🏗️ Construction de l'image Docker pour le staging..."
    docker build -t $IMAGE_NAME -f docker/staging/Dockerfile .
    
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
        
        # Affichage des logs du conteneur
        echo "📝 Logs du conteneur:"
        docker logs $CONTAINER_NAME
    else
        echo -e "${RED}❌ Échec du démarrage du conteneur${NC}"
        cleanup
    fi
else
    echo -e "${RED}❌ Les tests ont échoué. Déploiement annulé.${NC}"
    cleanup
fi
