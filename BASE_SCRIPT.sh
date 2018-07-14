#!/bin/bash

#
# Script's variables
#
SCRIPT_NAME=${0##*/};
SCRIPT_LOGFILE=${SCRIPT_NAME%.sh}.log;
SCRIPT_TIME=$(date "+%Y%m%d_%H%M%S");
SCRIPT_EXECUTOR=$(whoami);
VERBOSE="false";

################################################

#
# Functions
#

function printUsage() {
    echo "  Usage:  ${SCRIPT_NAME} [--help|-h]";
    echo "    --help, -h  Prints this help an exits.";
}

function logInfo() {
    my_msg=$1;
    echo "  [${SCRIPT_NAME} INFO $(date '+%Y%m%d %H%M%S')] ${my_msg}";
}

function logError() {
    my_msg=$1;
    echo "  [${SCRIPT_NAME} ERROR $(date '+%Y%m%d %H%M%S')] ${my_msg}";
}

function verbose() {
    if [[ "true" == ${VERBOSE} ]]
    then
        my_msg=$1;
        echo "  [${SCRIPT_NAME} VERBOSE $(date '+%Y%m%d %H%M%S')] ${my_msg}";
    fi
}

function _initScript() {
    # Setting variables
    # Input validations
}

################################################

#
# Main
#

_initScript $@;

# code...
logInfo "Hello, world!";
