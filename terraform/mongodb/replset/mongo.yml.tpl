#cloud-config

rancher:
  console: ubuntu
  services:
    mongo:
      image: ${docker_image}
      restart: always
      ulimit: 
        nproc: 5000000
      environment:
      - MONGODB_AUTH=yes
      - MONGODB_USER=${username}
      - MONGODB_PASS=${password}
      - MONGODB_REPLSET=yes
      - MONGODB_REPLSET_NAME=${replset_name}
      - MONGODB_BOOTSTRAP=no
      - MONGODB_DATABASE=${database}
      volumes:
      - /data/db:/var/lib/mongodb
      ports:
      - '${port}:27017'
