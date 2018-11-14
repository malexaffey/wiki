#!/bin/bash

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]
  then
    echo "Invalid arguments: ./create_project.sh PROJECT_NAME SERVICE_NAME SERVICE_PORT"
    exit 1
fi

PROJECT_NAME=$1
SERVICE_NAME=$2
SERVICE_PORT=$3

TEMPLATE_DIR=template
SRC_DIR=/opt/singnet/$PROJECT_NAME
PROTO_DIR=$SRC_DIR/service_spec
PROTO_FILE=$PROTO_DIR/$PROJECT_NAME.proto
SERVER_PY_FILE=$SRC_DIR/server.py
CLIENT_PY_FILE=$SRC_DIR/client.py
BUILD_SCRIPT_FILE=$SRC_DIR/build.sh

SERVICE_JSON_FILE=$SRC_DIR/service.json
DAEMON_CONFIG_DIRNAME=config
DAEMON_CONFIG_FILENAME=snetd.config.json
DAEMON_CONFIG_DIR=$SRC_DIR/$DAEMON_CONFIG_DIRNAME
DAEMON_CONFIG_FILE=$DAEMON_CONFIG_DIR/$DAEMON_CONFIG_FILENAME
START_SERVICE_SCRIPT_FILE=$SRC_DIR/publishAndStartService.sh
CLIENT_TEST_SCRIPT_FILENAME=testServiceRequest.sh
CLIENT_TEST_SCRIPT_FILE=$SRC_DIR/$CLIENT_TEST_SCRIPT_FILENAME

TEMPLATE_PROTO=$TEMPLATE_DIR/proto.template.proto
TEMPLATE_BUILD_SCRIPT=$TEMPLATE_DIR/build.template.sh
TEMPLATE_SERVER=$TEMPLATE_DIR/server.template.py
TEMPLATE_CLIENT=$TEMPLATE_DIR/client.template.py
TEMPLATE_SERVICE_JSON=$TEMPLATE_DIR/serviceJson.template.json
TEMPLATE_DAEMON_CONFIG_FILE=$TEMPLATE_DIR/daemonConfigFile.template.json
TEMPLATE_START_SERVICE_SCRIPT=$TEMPLATE_DIR/publishAndStartService.template.sh
TEMPLATE_CLIENT_TEST_SCRIPT=$TEMPLATE_DIR/testService.template.sh

PROJECT_TAG=__PROJECT__
SERVICE_PORT_TAG=__SERVICE_PORT__
SERVICE_NAME_TAG=__SERVICE_NAME__
DAEMON_CONFIG_FILE_TAG=__DAEMON_CONFIG_FILE__
TEST_SCRIPT_FILENAME_TAG=__TEST_SCRIPT_FILENAME__

PYTHON_PB2=__PYTHON_PB2__
PYTHON_PB2_GRPC=__PYTHON_PB2_GRPC__

if [ -d "$SRC_DIR" ] || [ -f $SRC_DIR ]; then
    echo "ERROR: $SRC_DIR already exists"
    exit 1
fi

mkdir -p $PROTO_DIR
mkdir -p $SRC_DIR
mkdir -p $DAEMON_CONFIG_DIR

cat $TEMPLATE_PROTO | sed "s/$PROJECT_TAG/$PROJECT_NAME/g" > $PROTO_FILE
cat $TEMPLATE_BUILD_SCRIPT > $BUILD_SCRIPT_FILE

cat $TEMPLATE_SERVER | sed "s/$PROJECT_TAG/$PROJECT_NAME/g" | sed "s/$SERVICE_PORT_TAG/$SERVICE_PORT/g" | sed "s/$PYTHON_PB2/${PROJECT_NAME}_pb2/g" | sed "s/$PYTHON_PB2_GRPC/${PROJECT_NAME}_pb2_grpc/g" > $SERVER_PY_FILE
cat $TEMPLATE_CLIENT | sed "s/$PROJECT_TAG/$PROJECT_NAME/g" | sed "s/$SERVICE_PORT_TAG/$SERVICE_PORT/g" | sed "s/$PYTHON_PB2/${PROJECT_NAME}_pb2/g" | sed "s/$PYTHON_PB2_GRPC/${PROJECT_NAME}_pb2_grpc/g" > $CLIENT_PY_FILE

cat $TEMPLATE_SERVICE_JSON | sed "s/$PROJECT_TAG/$PROJECT_NAME/g" | sed "s/$SERVICE_NAME_TAG/$SERVICE_NAME/g" > $SERVICE_JSON_FILE
cat $TEMPLATE_DAEMON_CONFIG_FILE | sed "s/$SERVICE_PORT_TAG/$SERVICE_PORT/g" > $DAEMON_CONFIG_FILE
cat $TEMPLATE_CLIENT_TEST_SCRIPT > $CLIENT_TEST_SCRIPT_FILE
cat $TEMPLATE_START_SERVICE_SCRIPT | sed "s/$DAEMON_CONFIG_FILE_TAG/$DAEMON_CONFIG_DIRNAME\/$DAEMON_CONFIG_FILENAME/g" | sed "s/$TEST_SCRIPT_FILENAME_TAG/$CLIENT_TEST_SCRIPT_FILENAME/g" > $START_SERVICE_SCRIPT_FILE

chmod 755 $START_SERVICE_SCRIPT_FILE
chmod 755 $CLIENT_TEST_SCRIPT_FILE
chmod 755 $BUILD_SCRIPT_FILE
