#cloud-config

rancher:
  services:
    mongodb:
      image: ${docker_image}
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
      restart: always
  services_include:
    ubuntu-console: true
