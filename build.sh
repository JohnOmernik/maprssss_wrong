#!/bin/bash

IMG="maprssss"

sudo docker build -t $IMG .




#APP_VER="3.1.0.0"
#APP_IMG_NAME="streamsets"
#APP_IMG_TAG="$APP_VER"
#APP_IMG="${ZETA_DOCKER_REG_URL}/${APP_IMG_NAME}:${APP_IMG_TAG}"
#REQ_APP_IMG_NAME="zetabase"


#APP_URL_BASE="https://archives.streamsets.com/datacollector/${APP_VER}/tarball"
#APP_URL_FILE="streamsets-datacollector-core-${APP_VER}.tgz"
#APP_URL="${APP_URL_BASE}/${APP_URL_FILE}"

#APP_INST_DIR="streamsets-datacollector-$APP_VER"

