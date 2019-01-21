#! /bin/bash

SPARK_V="2.3.1"

/opt/mapr/server/configure.sh  -c -secure -N ${MAPR_CLUSTER} -C ${MAPR_CLDB}

echo ${MAPR_TICKET} > ${MAPR_TICKETFILE_LOCATION}

echo "${MAPR_SSLTRUSTSTORE}" | base64 --decode >  /opt/mapr/conf/ssl_truststore

for host in ${MASTER_SLAVES}
do
echo ${host} >> /opt/mapr/spark/spark-${SPARK_V}/conf/slaves
done

HN=`hostname -f`
HI=`getent hosts | grep ${HN} | awk '{print $1}'`
env_file="/opt/mapr/spark/spark-${SPARK_V}/conf/spark-env.sh"
echo "export SPARK_MASTER_HOST=${HN}" >> ${env_file}
echo "export SPARK_MASTER_IP=${HI}" >> ${env_file}

case ${NODE_ROLE} in
	master)
		/opt/mapr/spark/spark-${SPARK_V}/sbin/start-master.sh 
		;;
	worker)
		/opt/mapr/spark/spark-${SPARK_V}/sbin/start-slave.sh ${SPARK_MASTER_SERVICE}
		;;
esac

#/opt/mapr/spark/spark-${SPARK_V}/bin/spark-shell

sleep 100000
