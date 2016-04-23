echo "Preparing a testing environment..."
echo "Running a mongod server as a primary member of replication set using keyFile auth in cluster and a prorected database using an username and password..."
echo "Should starts and configure a primary mongo server..."

IMAGE=vymarkov/mongo
COMPOSE_FILE=docker-compose.yml
COMPOSE_PROJECT_NAME=mongo_testing
USERNAME=admin
PASSWORD=password

docker version
cmd="docker run -d -e AUTH=yes -e MONGODB_REPLSET_NAME=replsetname -e MONGODB_REPLSET=yes -e MONGODB_REPLSET_ROLE=primary -e MONGODB_USER=$USERNAME -e MONGODB_PASS=$PASSWORD $IMAGE"

echo $cmd
CONTAINER_ID=$($cmd)
echo $CONTAINER_ID
docker logs -f $CONTAINER_ID &
sleep 10

echo
echo "Show container\`s environment variables"
docker exec $CONTAINER_ID env
echo
echo "Runing the command in the container..."
docker exec $CONTAINER_ID mongo -u admin -p password admin --eval 'db.version()'
docker exec $CONTAINER_ID mongo -u admin -p password admin --eval 'rs.status()'

docker kill $CONTAINER_ID
docker rm -f $CONTAINER_ID