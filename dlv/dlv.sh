#!/bin/bash

# Script's variables
SCRIPT_NAME=${0##*/};
SCRIPT_TIME=$(date "+%Y%m%d_%H%M%S");
SCRIPT_UNIQUE_NAME=${SCRIPT_NAME%.sh}.${SCRIPT_TIME};
SCRIPT_LOGFILE=logs/${SCRIPT_UNIQUE_NAME}.log;
SCRIPT_ERRORFILE=logs/${SCRIPT_UNIQUE_NAME}.err;
SCRIPT_EXECUTOR=$(whoami);
VERBOSE="false";

URL_REGEX="(https?):\/\/[A-Za-z0-9\+&@#/%?=~_|!:,.;-]*[-A-Za-z0-9\+&@#/%=~_|]";
COMMENT_REGEX="^#";
INPUT_FILE="/home/pi/youtube-dl/urls.txt";
INPUT_FILE_BACKUP=logs/${SCRIPT_UNIQUE_NAME}.txt;
OUTPUT_FOLDER="/home/pi/rpi4mediaserver/nnlk-tmp/videos";
COOKIES_FILE="";
NUMBER_OF_URLS="";

TOTAL_TIME="";
ERRORS=0;
SUCCESS=0;

################################################

# Functions

function printUsage() {
    echo "  Usage:  ${SCRIPT_NAME} -i INPUT_FILE [-o OUTPUT_FOLDER] [-v]";
    echo "    INPUT_FILE    - Path to an existing file containing video URLs.";
    echo "    OUTPUT_FOLDER - Optional parameter to a directory to place the files into.";
}

function logInfo() {
    my_msg=$1;
    my_log="  [INFO  $(date '+%Y.%m.%d %H:%M:%S')] ${my_msg}";

    echo "${my_log}";
    echo "${my_log}" >> ${SCRIPT_LOGFILE} &
}

function logError() {
    my_msg=$1;
    my_log="  [ERROR $(date '+%Y.%m.%d %H:%M:%S')] ${my_msg}";

    echo "${my_log}";
    echo "${my_log}" >> ${SCRIPT_LOGFILE} &
}

function verbose() {
    if [[ "true" == ${VERBOSE} ]]
    then
        my_msg=$1;
        my_log="  [VERBOSE $(date '+%Y.%m.%d %H:%M:%S')] ${my_msg}";

        echo "${my_log}";
        echo "${my_log}" >> ${SCRIPT_LOGFILE} &
    fi
}

#
# Sets variables and performs input parameter validations
#
function initScript() {

    # Getting parameters
    while getopts 'i:o:c:v' option
    do
        case ${option} in
            i) INPUT_FILE="${OPTARG}";
               ;;
            o) OUTPUT_FOLDER="${OPTARG}";
               ;;
            c) COOKIES_FILE="${OPTARG}";
               ;;
            v) VERBOSE="true";
               ;;
            ?) printUsage;
               exit 1;
               ;;
        esac
    done

    shift "$(($OPTIND - 1))"

    # Input file validation
    if [[ ${INPUT_FILE} == "" ]]
    then
        echo "  Missing parameter!";
        printUsage;
        exit 1;
    elif [[ ! -f ${INPUT_FILE} ]]
    then
        echo "  Input file does not exist: ${INPUT_FILE}";
        printUsage;
        exit 1;
    fi

    # Cookies file validation
    if [[ ${COOKIES_FILE} != "" ]] && [[ ! -f ${COOKIES_FILE} ]]
    then
        echo "  Cookies file does not exist: ${COOKIES_FILE}";
        printUsage;
        exit 1;
    fi

    # Setting NUMBER_OF_URLS and creating log files
    NUMBER_OF_URLS=`cat ${INPUT_FILE} | wc -l`;
    > ${SCRIPT_LOGFILE}
    > ${SCRIPT_ERRORFILE}
    cat ${INPUT_FILE} > ${INPUT_FILE_BACKUP}
    chmod 777 ${SCRIPT_LOGFILE} ${SCRIPT_ERRORFILE} ${INPUT_FILE_BACKUP}
}

function downloadVideos() {
    start=`date "+%s"`;
    counter=0;

    cookies_parameter="";
    if [[ "${COOKIES_FILE}" != "" ]]
    then
        verbose "Using cookies: ${COOKIES_FILE}";
        cookies_parameter="--cookies \"${COOKIES_FILE}\"";
    fi

    while read URL
    do
        ((counter++));
        logInfo "(${counter} / ${NUMBER_OF_URLS}) Working on: '${URL}'...";

        if [[ ${URL} =~ ${COMMENT_REGEX} ]]
        then
            verbose "Skipping commented URL: '${URL}'";
            continue;
        elif [[ ! ${URL} =~ ${URL_REGEX} ]]
        then
            logError "Skipping invalid URL: '${URL}'";
            continue;
        fi

        sudo python3 /usr/bin/youtube-dl --format 'best[ext=mp4][filesize<500M]/best[filesize<500M]/worst' --output "${OUTPUT_FOLDER}/%(extractor)s/%(title)s - %(id)s.%(ext)s" --no-overwrites --restrict-filenames --recode-video mp4 --write-info-json --write-thumbnail --download-archive archive.txt ${cookies_parameter} "${URL}"

        if [[ !$? -eq 0 ]]
        then
            ((ERRORS++));
            logError "  An error ocurred while downloading video: '${URL}'";
            echo ${URL} >> ${SCRIPT_ERRORFILE};
        else
            ((SUCCESS++));
        fi

    done < ${INPUT_FILE}

    if [[ "${COOKIES_FILE}" != "" ]]
    then
        sudo rm '"cookies.txt"';
    fi

    end=`date "+%s"`;
    TOTAL_TIME=$((end - start));
}

function printSummary() {
    totalTime=`date -ud "@${TOTAL_TIME}" "+%H:%M:%S"`;

    echo " ";
    echo "  -----------------------------------------------";
    echo "  SUMMARY";
    echo "  -----------------------------------------------";
    echo "  Input URLs:    ${NUMBER_OF_URLS}";
    echo "  Output folder: ${OUTPUT_FOLDER}";
    echo "  Success:       ${SUCCESS}";
    echo "  Errors:        ${ERRORS}";
    echo "  Total time:    ${totalTime}"
    echo "  Log File:      ${SCRIPT_LOGFILE}"
    echo "  Errors:        ${SCRIPT_ERRORFILE}"
    echo "  Input backup:  ${INPUT_FILE_BACKUP}"
    echo "  -----------------------------------------------";
}

################################################

# Main

initScript $@;
downloadVideos;
printSummary;
