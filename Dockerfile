FROM mongo:3.4
MAINTAINER Vitaly Markov "vymarkov@gmail.com"

ENV AUTH=no REST_INTERFACE=no REPLSET=no STORAGE_ENGINE=wiredTiger JOURNALING=yes

# /docker-entrypoint-initdb.d
RUN mkdir /var/lib/mongodb /srv/mongo
RUN apt-get update &&\
	apt-get install pwgen -y

COPY ./bin/entrypoint.sh /entrypoint.sh
COPY ./bin/set_mongodb_password.sh /set_mongodb_password.sh
COPY boot.js /srv/mongo
COPY bootreplset.js /srv/mongo
COPY mongod.conf /etc/mongod.conf
COPY mongodb-keyfile /etc/mongod/keyfile

ENTRYPOINT ["/entrypoint.sh"]
CMD [""]