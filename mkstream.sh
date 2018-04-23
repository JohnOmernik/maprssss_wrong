#!/bin/bash

. ./env.list

POSIX_MNT="${MAPR_MOUNT_PATH}/${MAPR_CLUSTER}"
POSIX_VOL="${POSIX_MNT}${MAPR_SYSLOG_VOLUME_LOCATION}"
POSIX_STREAM="${POSIX_MNT}${MAPR_SYSLOG_STREAM_LOCATION}"

MAPRCLI="maprcli"
#MAPRCLI="/home/zetaadm/homecluster/zetago/zeta fs mapr maprcli -U=mapr"
if [ ! -d "$POSIX_VOL" ]; then
    $MAPRCLI volume create -path $MAPR_SYSLOG_VOLUME_LOCATION -rootdirperms 775 -user "${MAPR_CONTAINER_USER}:fc,a,dump,restore,m,d mapr:fc,a,dump,restore,m,d" -ae $MAPR_CONTAINER_USER -name "prod.data.sssyslog"
fi


$MAPRCLI stream create -path $MAPR_SYSLOG_STREAM_LOCATION -defaultpartitions $MAPR_SYSLOG_DEFAULT_PARTITIONS -produceperm "\(u:mapr\|g:$MAPR_CONTAINER_GROUP\|u:$MAPR_CONTAINER_USER\)" -consumeperm "\(u:mapr\|g:$MAPR_CONTAINER_GROUP\|u:$MAPR_CONTAINER_USER\)" -topicperm "\(u:mapr\|g:$MAPR_CONTAINER_GROUP\|u:$MAPR_CONTAINER_USER\)" -adminperm "\(u:mapr\|g:$MAPR_CONTAINER_GROUP\|u:$MAPR_CONTAINER_USER\)"
 
rm -rf ./conf
