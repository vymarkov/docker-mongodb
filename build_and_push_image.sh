TAG=${IMAGE_TAG:-"latest"}

docker build --no-cache -t vymarkov/mongo -f Dockerfile .
docker tag vymarkov/mongo vymarkov/mongo:$TAG
docker login --username $DOCKER_REGISTRY_USERNAME --email $DOCKER_REGISTRY_EMAIL --password $DOCKER_REGISTRY_PASS
docker push vymarkov/mongo:$TAG