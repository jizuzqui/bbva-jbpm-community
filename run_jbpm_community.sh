#!/bin/bash
JBPM_PERSISTENT_DIR=$1
# JBPM_BBVA_IMAGE_VERSION=$2
JBPM_IMAGE_NAME=jizuzquiza/jbpm-bbva-holding
JBPM_CONTAINER_NAME=jbpm-bbva-holding
JBOSS_HOME=/opt/jboss/wildfly
CPUS_NUMBER="$(cat /proc/cpuinfo | grep processor | wc -l)"
CPUS_DIVISOR=2
CPUS_CONTAINER=$CPUS_NUMBER

if [ $CPUS_NUMBER -gt 2  ]
then
	echo "DENTRO ID"
	CPUS_CONTAINER=$((CPUS_NUMBER / CPUS_DIVISOR))
fi

echo "Número de cpus $CPUS_CONTAINER"

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
mkdir -p $JBPM_PERSISTENT_DIR/mock-services

# Downloading latest image version...
docker pull $JBPM_IMAGE_NAME:$JBPM_BBVA_IMAGE_VERSION 

# Runing jBPM docker image
docker run -p 8080:8080 -p 8001:8001 -p 8082:8082 -p 9990:9990 -p 8787:8787 -p 1080:1080 -p 9092:9092 -p 8090:8090 \
    -m 4096m --cpus=$CPUS_CONTAINER \
    --mount source=jbpm-repositories,target=/opt/jboss/.m2/ \
    --mount source=jbpm-repositories,target=/opt/jboss/repositories/ \
    --mount source=jbpm-data,target=/opt/jboss/data/ \
    --mount source=jbpm-user-group-data,target=$JBOSS_HOME/standalone/configuration/users_groups_data/ \
    --mount source=jbpm-mock-services,target=/opt/jboss/mock-server/services/ \
    --mount source=jbpm-ssh-keys,target=/home/jboss/.ssh \
    -d --name $JBPM_CONTAINER_NAME $JBPM_IMAGE_NAME:$JBPM_BBVA_IMAGE_VERSION
