#!/bin/bash
JBPM_PERSISTENT_DIR=$1
JBPM_BBVA_IMAGE_VERSION=$2
JBPM_IMAGE_NAME=jizuzquiza/jbpm-bbva-holding
JBPM_CONTAINER_NAME=jbpm-bbva-holding
JBOSS_HOME=/opt/jboss/wildfly

if [ -z "$JBPM_PERSISTENT_DIR" ]
then
        JBPM_PERSISTENT_DIR=$HOME/jbpm-container-persistence
fi

if [ -z "$JBPM_BBVA_IMAGE_VERSION" ]
then
        JBPM_BBVA_IMAGE_VERSION=latest
fi

docker stop $JBPM_CONTAINER_NAME
docker rm $JBPM_CONTAINER_NAME

mkdir -p $JBPM_PERSISTENT_DIR/logs
mkdir -p $JBPM_PERSISTENT_DIR/repositories/mvn_home
mkdir -p $JBPM_PERSISTENT_DIR/data
mkdir -p $JBPM_PERSISTENT_DIR/user_group_data

docker pull $JBPM_IMAGE_NAME:$JBPM_BBVA_IMAGE_VERSION 

docker run -p 8080:8080 -p 8001:8001 -p 8082:8082 -p 9990:9990 \
    --mount source=jbpm-logs,target=$JBOSS_HOME/standalone/log/ \
    --mount source=jbpm-repositories,target=/opt/jboss/.m2/ \
    --mount source=jbpm-repositories,target=/opt/jboss/repositories/ \
    --mount source=jbpm-data,target=/opt/jboss/data/ \
    --mount source=jbpm-user-group-data,target=$JBOSS_HOME/standalone/configuration/ \
    -d --name $JBPM_CONTAINER_NAME $JBPM_IMAGE_NAME:$JBPM_BBVA_IMAGE_VERSION

# docker run -p 8080:8080 -p 8001:8001 -p 8082:8082 -p 9990:9990 \
#    -v $JBPM_PERSISTENT_DIR/logs/:$JBOSS_HOME/standalone/log/ \
#    -v $JBPM_PERSISTENT_DIR/repositories/mvn_home/:/opt/jboss/.m2/ \
#    -v $JBPM_PERSISTENT_DIR/repositories/:/opt/jboss/repositories/ \
#    -v $JBPM_PERSISTENT_DIR/data/:/opt/jboss/data/ \
#    -v $JBPM_PERSISTENT_DIR/user_group_data/:$JBOSS_HOME/standalone/configuration/ \
#    -d --name $JBPM_CONTAINER_NAME $JBPM_IMAGE_NAME:$JBPM_BBVA_IMAGE_VERSION
