echo "Preparing a testing environment..."

IMAGE=vymarkov/mongo
COMPOSE_FILE=./docker-compose/docker-compose.yml
COMPOSE_PROJECT_NAME=mongo_testing
CONTAINER_NAME=primary

docker-compose -f $COMPOSE_FILE kill
docker-compose -f $COMPOSE_FILE rm -f 

user=admin
pass=password

echo "Docker version"
docker version
echo "Docker Compose version"
docker-compose version 

cmd="docker-compose -f $COMPOSE_FILE ps"
cmd="docker-compose -f $COMPOSE_FILE up -d consul"
cmd="docker-compose -f $COMPOSE_FILE up -d registrator"
sleep 5
cmd="docker-compose -f $COMPOSE_FILE up -d"

echo $cmd
$cmd

docker-compose -f $COMPOSE_FILE logs primary secondary arbiter registrator &

echo "Sleeping..."
sleep 20

echo
echo "Runing the command in the container..."

docker exec $CONTAINER_NAME mongo -u $user -p $pass admin --eval 'db.version()'
echo "Fetching status of replSet..."
docker exec $CONTAINER_NAME mongo -u $user -p $pass admin --eval 'rs.status()'

echo ""
echo "Adding a new member..."
docker exec $CONTAINER_NAME mongo -u $user -p $pass admin --eval 'rs.add("secondary.mongo")'
# docker exec secondary ping primary.mongo.service.nodebb

echo ""
echo "Adding a new member..."
docker exec $CONTAINER_NAME mongo -u $user -p $pass admin --eval 'rs.addArb("arbiter.mongo")'

echo "Sleeping..."
sleep 15

echo "Fetching status of replSet..."
docker exec $CONTAINER_NAME mongo -u $user -p $pass admin --eval 'rs.status()'

docker-compose -f $COMPOSE_FILE kill

echo "Deleting stopped containers..."
docker rm -v `docker ps -a -q -f status=exited`

echo "Deleting dangling volumes..."
docker volume rm $(docker volume ls -q -f dangling=true)