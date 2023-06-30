#!/bin/bash
#
# Install the NMState operator
#

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
function error() {
    JOB="$0"              # job name
    LASTLINE="$1"         # line of error occurrence
    LASTERR="$2"          # error code
    echo "ERROR in ${JOB} : line ${LASTLINE} with exit code ${LASTERR}"
    exit 1
}
trap 'error ${LINENO} ${?}' ERR

COMMAND=/usr/local/bin/oc

echo "Create the namespace"
_RESULT=$(${COMMAND} apply -f ./files/nmstate-namespace.yaml)
echo "$_RESULT"

echo "Create the Operator Group"
_RESULT=$(${COMMAND} apply -f ./files/nmstate-og.yaml)
echo "$_RESULT"

echo "Create the Operator"
_RESULT=$(${COMMAND} apply -f ./files/nmstate-operator.yaml)
echo "$_RESULT"

_DELAY=30
_COUNT=0
echo "Wait up to ${_DELAY}s for the CSV installation to complete
until [ "$(oc get clusterserviceversion -n openshift-nmstate -o jsonpath='{.items[0].status.phase}')"  == "Succeeded"" ]
    sleep 1
    $_COUNT = $_COUNT + 1
    if [ $_COUNT -eq $_DELAY]
        exit 1
    fi
done

echo "Create the instance"
_RESULT=$(${COMMAND} apply -f ./files/nmstate-instance.yaml)
echo "$_RESULT"