#!/bin/bash

# vars that should be passed as parameter to this script at some point
CARTE_USER=cluster
CARTE_PASSWORD=cluster
CARTE_HOSTNAME=host.docker.internal
CARTE_PORT=8081
PDI_JOB_PATH=/Users/diethardsteiner/git/airflow-example/pdi/jobs-and-transformations/job-write-to-log.kjb
PDI_LOG_LEVEL=Basic
SLEEP_INTERVAL_SECONDS=5

# local vars
set PDI_JOB_ID
set PDI_JOB_STATUS
CARTE_SERVER_URL=http://${CARTE_USER}:${CARTE_PASSWORD}@${CARTE_HOSTNAME}:${CARTE_PORT}

# start PDI job and get job id
PDI_JOB_ID=$(curl -s "${CARTE_SERVER_URL}/kettle/executeJob/?job=${PDI_JOB_PATH}&level=${PDI_LOG_LEVEL}" | xmlstarlet sel -t -m '/webresult/id' -v . -n)

echo "The PDI job ID is: " ${PDI_JOB_ID}

function getPDIJobStatus {
  curl -s "${CARTE_SERVER_URL}/kettle/jobStatus/?name=job-write-to-log&id=${PDI_JOB_ID}&xml=Y" | xmlstarlet sel -t -m '/jobstatus/status_desc' -v . -n
}

function getPDIJobFullLog {
  curl -s "${CARTE_SERVER_URL}/kettle/jobStatus/?name=job-write-to-log&id=${PDI_JOB_ID}&xml=Y" | xmlstarlet sel -t -m 'jobstatus/result/log_text' -v . -n | fold -w
}

PDI_JOB_STATUS=$(getPDIJobStatus)

# loop as long as the job is running
while [ ${PDI_JOB_STATUS} = "Running" ]
do
  PDI_JOB_STATUS=$(getPDIJobStatus)
  echo "The PDI job status is: " ${PDI_JOB_STATUS}
  echo "I'll check in ${SLEEP_INTERVAL_SECONDS} seconds again"
  # check every x seconds
  sleep ${SLEEP_INTERVAL_SECONDS}
done 

# get and print full pdi job log
echo "The PDI job status is: " ${PDI_JOB_STATUS}
echo "Printing full log ..."
echo ""
echo $(getPDIJobFullLog)