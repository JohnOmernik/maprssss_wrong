#!/bin/bash


. ./env.list

PORTS="-p ${SYSLOG_UDP_PORT}:${SYSLOG_UDP_PORT}/udp -p ${SYSLOG_TCP_PORT}:${SYSLOG_TCP_PORT}/tcp -p ${STREAMSETS_TCP_PORT}:${STREAMSETS_TCP_PORT}/tcp"
VOLS="-v=/tmp/mapr_ticket:/tmp/mapr_ticket:ro -v=${APP_CONF_DIR}:/app/conf:rw -v=${APP_DATA_DIR}:/app/data:rw -v=${APP_LOG_DIR}:/app/logs:rw -v=${APP_RESOURCE_DIR}:/app/resources:rw -v=${APP_SBIN_DIR}:/app/sbin:rw" 

echo ""
echo "Some checks for testing"
echo "-----------------------"
echo "Does the MAPR_CONTAINER_USER exist on the computer you are running from"
id $MAPR_CONTAINER_USER
if [ "$?" != "0" ]; then
    echo "Warning: The MAPR_CONTAINER_USER $MAPR_CONTAINER_USER does not exist on this system. That means the config files etc that are stored on this system may have permissions issues"
    echo ""
    echo "We will proceed UNLESS the MAPR_CONTAINER_UID is already in use on this system (next check"_
    echo ""
    id $MAPR_CONTAINER_UID
    if [ "$?" == "0" ]; then
        echo "The specified container user doesn't exist, and the UID of the container DOES exist, thus, we are going to exit"
        exit 1
    fi
fi



if [ ! -f "$MAPR_TICKETFILE_LOCATION" ] && [ "$MAPR_TICKETFILE_LOCATION" != "" ]; then
    echo "There needs to be a ticket in $MAPR_TICKETFILE_LOCATION for secure clusters. If this is not a securecluster, then just make MAPR_TICKETFILE_LOCATION empty in env.list"
    exit 1
fi


if [ ! -d "$APP_HOME" ]; then
    echo "The Streamsets Home Directory doesn't appear to be created at $APP_HOME"
    echo "Creating Now"
    mkdir -p $APP_HOME && mkdir -p $APP_CONF_DIR && mkdir -p $APP_LOG_DIR && mkdir -p $APP_SBIN_DIR && mkdir -p $APP_RESOURCE_DIR && mkdir -p $APP_DATA_DIR && mkdir -p $APP_CERT_LOC
    if [ "$?" != "0" ]; then
        echo "Error on Directory Creation - Exiting"
        exit 1
    fi
    sudo chown -R $MAPR_CONTAINER_USER:$MAPR_CONTAINER_GROUP $APP_HOME && sudo chown 770 $APP_CONF_DIR && sudo chmod g+s $APP_DATA_DIR && sudo chmod g+s $APP_RESOURCE_DIR && sudo chmod g+s $APP_LOG_DIR
    if [ "$?" != "0" ]; then
        echo "Error on permission setting - Exiting"
        exit 1
    fi
    echo "getting etc"
    sudo docker run -it --env-file ./env.list --rm -v=$APP_CONF_DIR:/app/conf:rw $IMG cp -R ${SDC_DIST}/etc /app/conf/
    if [ "$?" != "0" ]; then
        echo "Erroring copying etc files from SS Image - Exiting"
        exit 1
    fi
    echo "getting libexec"
    sudo docker run -it --env-file ./env.list --rm -v=$APP_CONF_DIR:/app/conf:rw $IMG cp -R ${SDC_DIST}/libexec /app/conf/
    if [ "$?" != "0" ]; then
        echo "Error copying libexec folder from SS Image - Exiting"
        exit 1
    fi
    echo "Moving Default Config Items"
    sudo mv $APP_CONF_DIR/etc/* $APP_CONF_DIR &&  sudo cp $APP_CONF_DIR/libexec/sdc-env.sh $APP_CONF_DIR/ && sudo cp $APP_CONF_DIR/libexec/sdcd-env.sh $APP_CONF_DIR/
    if [ "$?" != "0" ]; then
        echo "Erroring Moving Default config items - Exiting"
        exit 1
    fi
    # test for some failure we don't want /etc removed"
#    RMDIR="$APP_CONF_DIR/etc"
#    RMDIR2="$APP_CONF_DIR/libexec"
#    if [ "$RMDIR" == "/etc" ] || [ "$RMDIR2" == "/libexec" ]; then
#        echo "OOPS"
#        exit 1
#    fi

#    sudo rm -rf $RMDIR
#    sudo rm -rf $RMDIR2
#    sudo chown -R $MAPR_CONTAINER_USER:$MAPR_CONTAINER_GROUP $APP_CONF_DIR
#    sudo chmod -R 770 $APP_CONF_DIR
    echo "Updating Config settings"
    APP_SDC_CONF="$APP_CONF_DIR/sdc.properties"
    # First we disable the http port - HTTPS ONLY!
    sudo sed -r -i "s/^http\.port=.*/http.port=-1/g" $APP_SDC_CONF && sudo sed -r -i "s/^https.port=.*/https.port=$STREAMSETS_TCP_PORT/g" $APP_SDC_CONF
    if [ "$?" != "0" ]; then
        echo "Erroring updating config files -exiting"
        exit
    fi


####################################################################################

    cat > ./start.sh << EOS
#!/bin/bash

export SDC_DIST="/opt/streamsets/streamsets-datacollector-${APP_VER}"
export SDC_HOME="${SDC_DIST}"
export SDC_CONF="/app/conf"
export MAPR_VERSION=$MAPR_VERSION
export MAPR_MEP_VERSION=$MAPR_MEP_VERSION
echo "Copying over ENV Info"
cp /app/conf/sdc-env.sh $SDC_DIST/libexec/
cp /app/conf/sdcd-env.sh $SDC_DIST/libexec/

chmod 600 /app/conf/form-realm.properties

echo "Setting up MapR"
$SDC_DIST/bin/streamsets setup-mapr

echo "Starting Stream Sets"
$SDC_DIST/bin/streamsets dc
EOS
    sudo mv ./start.sh $APP_SBIN_DIR/
    sudo chown $MAPR_CONTAINER_USER:$MAPR_CONTAINER_GROUP $APP_SBIN_DIR/start.sh
    sudo chmod +x $APP_SBIN_DIR/start.sh
####################################################################################

fi


echo "To start Streamsets please run the following command"
echo ""
echo "/app/sbin/start.sh"
echo ""

sudo docker run -it $PORTS --env-file ./env.list \
$VOLS \
   --device /dev/fuse \
   --security-opt apparmor:unconfined \
   $IMG /bin/bash
