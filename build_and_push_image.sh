TAG=${IMAGE_TAG:-"latest"}

docker build --no-cache -t vymarkov/mongo -f Dockerfile .
docker tag vymarkov/mongo vymarkov/mongo:$TAG
docker push vymarkov/mongo:$TAG