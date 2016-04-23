#!/bin/bash
set -m

chmod 600 /etc/mongod/keyfile

export REST=${REST_INTERFACE:-"no"}
export REST=${MONGODB_REST_INTERFACE:-"$REST"}
export REPLSET=${REPLSET:-"no"}
export REPLSET=${MONGODB_REPLSET:-${REPLSET}}
export REPLSET_NAME=${MONGODB_REPLSET_NAME:-"rs0"}
export ROLE=${MONGODB_REPLSET_ROLE:-"secondary"}
 
export DATABASE=${MONGODB_DATABASE:-"admin"}

export USER=${MONGODB_USER:-"admin"}
export PASS=${MONGODB_PASS:-$(pwgen -s 21 1)}

export AUTH=${MONGODB_AUTH:-"$AUTH"}

BOOTSTRAP=${MONGODB_BOOTSTRAP:-"no"}
export FIRST_BOOT=no

if [ ! -f /data/db/.mongodb_password_set ]; then
  FIRST_BOOT=yes
fi

cmd="mongod --config /etc/mongod.conf --storageEngine $STORAGE_ENGINE"

if [ "$JOURNALING" == "no" ]; then
    cmd="$cmd --nojournal"
fi

if [ "$OPLOG_SIZE" != "" ]; then
    cmd="$cmd --oplogSize $OPLOG_SIZE"
fi

if [ "$AUTH" == "yes" ]; then
  if [ "$REPLSET" != "yes" ]; then
    cmd="$cmd --auth" 
    
    if [ ! -f /data/db/.mongodb_password_set ]; then
      echo $cmd
      $cmd &
    
      ./set_mongodb_password.sh
    fi  
  fi
fi

# enable a rest interface for primary and secondary members
# if the REST variable was specified with 'yes' value
# by default is set to 'no' or was specified in the mongod.conf file
if [ "$ROLE" == "primary" ] || [ "$ROLE" == "secondary" ]; then
  if [ "$REST" == "yes" ]; then
    cmd="$cmd --httpinterface"
  fi
fi

if [ "$MONGODB_REPLSET_ROLE" == "primary" ]; then
  if [ "$AUTH" == "yes" ]; then
      cmd="$cmd --auth"
  fi
  
  if [ ! -f /data/db/.mongodb_password_set ]; then
    echo $cmd
    $cmd &
    
    ./set_mongodb_password.sh
  fi  
fi

if [ "$REPLSET" == "yes" ]; then
  if [ "$REPLSET_NAME" != "" ]; then
    cmd="$cmd --replSet $REPLSET_NAME"
  fi
  cmd="$cmd --keyFile /etc/mongod/keyfile"
fi

shutdownServer() {
  echo Trying to exit smoothly... 
  mongo admin -u $USER -p $PASS --eval "if(st = rs.status(), st.ok === 1 && st.members.length >= 3) { rs.stepDown(); }"
  mongo admin -u $USER -p $PASS --eval "db.shutdownServer()"
  echo 'MongoDB server successfully exited.'
  exit 143
}

trap "shutdownServer" SIGTERM

echo "$cmd"
$cmd &

if [ "$MONGODB_REPLSET_ROLE" == "primary" ] && [ "$FIRST_BOOT" == "yes" ]; then
  sleep 3

  mongo admin -u $USER -p $PASS /srv/mongo/bootreplset.js
fi

if [ "$BOOTSTRAP" == "yes" ] && [ "$FIRST_BOOT" == "yes" ]; then
  sleep 3
  
  mongo admin -u $USER -p $PASS /srv/mongo/boot.js
fi

wait ${!}