FROM mongo:3.2
MAINTAINER Vitaly Markov "v.y.markov@gmail.com"

ENV AUTH=no REST_INTERFACE=no REPLSET=no STORAGE_ENGINE=wiredTiger JOURNALING=yes

RUN mkdir /var/lib/mongodb /docker-entrypoint-initdb.d /srv/mongo
RUN apt-get update &&\
	apt-get install pwgen -y

# COPY initdb.d /docker-entrypoint-initdb.d
COPY ./bin/entrypoint.sh /entrypoint.sh
COPY ./bin/set_mongodb_password.sh /set_mongodb_password.sh
COPY boot.js /srv/mongo
COPY bootreplset.js /srv/mongo
COPY mongod.conf /etc/mongod.conf
COPY mongodb-keyfile /etc/mongod/keyfile

# EXPOSE 27017

ENTRYPOINT ["/entrypoint.sh"]