#! /bin/bash


export MAPR_TICKET="demo.mapr.com K5C2cDIfRoYD86S3RA9EESZFzxRj7Cc1j8UtOZSgBggsGmB4i77dEkz2VBdBnshUx2NUopeOTOqyroq4snFVvsE4AsPDtXzZ+gowvsfpJJXG8qwehJFh3aAvPJZ0EgeezWmqAJfSjIphP9SIgXuLUtNhwSYixEtWEgyel4G4IR6nHH2UJJC1ms79Ra7WRSIxSpLRaqyYbbpnZ02JAVmTRiaaGlmb8OFHADmB7V88ykb3KC1xHt0/qep6CL6rCZwqeS2oAxcsLbPpKVUpOW0b4HqDQPsGGuvp3YF+"
export MAPR_CLUSTER="demo.mapr.com"
export MAPR_CLDB="192.168.1.199"

###############################
## base64 encoded ssl_truststore
## cat /opt/mapr/conf/ssl_truststore| base64
###############################
export MAPR_SSLTRUSTSTORE="/u3+7QAAAAIAAAABAAAAAgANZGVtby5tYXByLmNvbQAAAWeGZACYAAVYLjUwOQAAAsswggLHMIIBr6ADAgECAgQYYPG9MA0GCSqGSIb3DQEBDQUAMBMxETAPBgNVBAMTCG1hcHJkZW1vMCAXDTE4MTIwNzAxNTkxOVoYDzIxMTgxMTEzMDE1OTE5WjATMREwDwYDVQQDEwhtYXByZGVtbzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAOxaiGNoJT8AhJKd47M6yelGK1XXokK7e94927Kz3UQEYOO3IzEBP8Rt1lWW6YN0KIXpaDbJ90kHtTFoYTA0L32Ke9TbgFxAGbT86TFAxkWnMo4VKRndXJ83s2fcGnAAkNel6Dd2w6WqRHjhlI5h159Yu7fku8K6+osPNd3gL7TNrxQJu8CdR7t7U8uAuv9RaHrszyrNZkz7odE7nTbXDuYkGWynmoQ9Eciu2onOlY0OMJqGExouXFg9rr9kogQ/rAHdBX28hA6bGG+q/2d6O00vB8crdxmMlG4qGr5Oylj8fIhVtOjKQxIDPnrYG88Bu/azkmLkpp24HO+KsoQWNWcCAwEAAaMhMB8wHQYDVR0OBBYEFOX2pVqRW48k0g6Uae2CCBRw1MZaMA0GCSqGSIb3DQEBDQUAA4IBAQBgyr7fp+AZ4jULPF5+OmGmRTSL2Gx5lGRlpCo0POPGSxy7A+E+4puUz0J5oay3oJNJZSBNeB5VnLyONewub+lU5a2XaXJuGHwUzxFmRqVcNGY99qdKYZGjETYZQxrkmkQ9fGqyVf+vs6YLWZxUDBKbCtAlIWJ7YXKrj4ALsUd9LRA009LDZRit5TbP0mWJN2oQURQpBwEZ6AmAghdtRuMx6TMRictBGylYdfDstGeS4q1FZWMN4lFm34bqIk7SprB59n3KlGGldtDfInMmZ9jVA6Q+Fi9wSaCmLx14qHo4xYd4Tb86aUDNDYSEkNpwb+SUCVIzdXf34SWzMEvRPpEdJuUmigxos5pQq81ehHxjhcvSGXo="

###############################
## this is the location of the built image
## in your repository
###############################
export DOCKER_IMAGE="hercules:1443/mapr-spark:latest"

##################################
### kubernetes paramters
### read more at https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/#meaning-of-cpu
##################################
export MASTER_MEMORY="2Gi"
export MASTER_CPU="500m"
export WORKER_MEMORY="1Gi"
export WORKER_CPU="500m"

##################################
### WARNING: do not use spark-master or spark_master
###          It causes conflicts with spark variables
### This are prefixes. The script appends
### a randon set of characters so you can deploy
### more than one cluster
##################################
export MASTER_POD="spark-mstr"
export WORKER_POD="spark-wrkr"

##################################
### How many workers do you want to start?
##################################
export NUMBER_OF_WORKERS=2


###################################
### Best practice put each cluster 
### on its own namespace
###################################
export NAMESPACE="spark-cluster"


##################################################
### If set, we will invoke spark submit and
### and the cluster will shutdown after processing
### This a path in MaR fs. It will be retrieved with hdfs dfs
###################################################
export SCALA_SCRIPT="/user/mapr/average_calc.scala"

###################################################################################
### Any chnages below this line require
### docker image or kubectl yaml changes
###################################################################################
export MAPR_TICKETFILE_LOCATION="/tmp/maprticket"

MASTER_TEMPLATE="spark_master.yaml"
WORKER_TEMPLATE="spark_worker.yaml"

export DOCKER_IMAGE=${DOCKER_IMAGE//\//\\/}
export MAPR_TICKET=${MAPR_TICKET//\//\\/}
export MAPR_TICKETFILE_LOCATION=${MAPR_TICKETFILE_LOCATION//\//\\/}
export MAPR_SSLTRUSTSTORE=${MAPR_SSLTRUSTSTORE//\//\\/}
export SCALA_SCRIPT=${SCALA_SCRIPT//\//\\/}
export POD_SUFFIX=`cat /dev/random | LC_CTYPE=C tr -dc "[:alpha:]" | head -c 6| tr '[:upper:]' '[:lower:]'`
if [ $? -ne 0 ]
then
   echo "======================================"
   echo " The random text generator was tested "
   echo " on Linux and MacOS"
   echo " It is possible it does not work on `uname`"
   echo "======================================"
fi

export MASTER_POD=${MASTER_POD}-${POD_SUFFIX}
export WORKER_POD=${WORKER_POD}-${POD_SUFFIX}

cat templates/${MASTER_TEMPLATE}.template| sed s/{{NAMESPACE}}/${NAMESPACE}/g|\
sed s/{{MASTER_POD}}/${MASTER_POD}/g|\
sed s/{{DOCKER_IMAGE}}/"${DOCKER_IMAGE}"/g|\
sed s/{{MAPR_TICKET}}/"${MAPR_TICKET}"/g |\
sed s/{{MAPR_TICKETFILE_LOCATION}}/${MAPR_TICKETFILE_LOCATION}/g |\
sed s/{{MAPR_CLUSTER}}/${MAPR_CLUSTER}/g|\
sed s/{{MAPR_CLDB}}/${MAPR_CLDB}/g|\
sed s/{{MAPR_SSLTRUSTSTORE}}/"${MAPR_SSLTRUSTSTORE}"/g |\
sed s/{{MASTER_MEMORY}}/${MASTER_MEMORY}/g |\
sed s/{{MASTER_CPU}}/${MASTER_CPU}/g > $MASTER_TEMPLATE

cat templates/${WORKER_TEMPLATE}.template| sed s/{{NAMESPACE}}/${NAMESPACE}/g|\
sed s/{{WORKER_POD}}/${WORKER_POD}/g|\
sed s/{{DOCKER_IMAGE}}/"${DOCKER_IMAGE}"/g|\
sed s/{{MAPR_TICKET}}/"${MAPR_TICKET}"/g |\
sed s/{{MAPR_TICKETFILE_LOCATION}}/${MAPR_TICKETFILE_LOCATION}/g |\
sed s/{{MAPR_CLUSTER}}/${MAPR_CLUSTER}/g|\
sed s/{{MAPR_CLDB}}/${MAPR_CLDB}/g|\
sed s/{{MAPR_SSLTRUSTSTORE}}/"${MAPR_SSLTRUSTSTORE}"/g |\
sed s/{{NUMBER_OF_WORKERS}}/${NUMBER_OF_WORKERS}/g |\
sed s/{{SPARK_MASTER_SERVICE}}/${MASTER_POD}:7077/g |\
sed s/{{WORKER_MEMORY}}/${WORKER_MEMORY}/g |\
sed s/{{WORKER_CPU}}/${WORKER_CPU}/g > $WORKER_TEMPLATE

