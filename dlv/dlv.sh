#!/bin/bash

# Script's variables
SCRIPT_NAME=${0##*/};
SCRIPT_TIME=$(date "+%Y%m%d_%H%M%S");
SCRIPT_UNIQUE_NAME=${SCRIPT_NAME%.sh}.${SCRIPT_TIME};
SCRIPT_LOCATION=/home/pi/git/com.zwolf.raspberrypi/dlv;
SCRIPT_LOGFILE=${SCRIPT_LOCATION}/logs/${SCRIPT_UNIQUE_NAME}.log;
SCRIPT_ERRORFILE=${SCRIPT_LOCATION}/logs/${SCRIPT_UNIQUE_NAME}.err;
SCRIPT_EXECUTOR=$(whoami);
VERBOSE="false";

# Regex
COMMENT_REGEX="^#";
URL_REGEX="(https?):\/\/[A-Za-z0-9\+&@#/%?=~_|!:,.;-]*[-A-Za-z0-9\+&@#/%=~_|]";

# Files
INPUT_FILE="${SCRIPT_LOCATION}//urls.txt";
INPUT_FILE_BACKUP=${SCRIPT_LOCATION}/logs/${SCRIPT_UNIQUE_NAME}.txt;
OUTPUT_FOLDER="/srv/dev-disk-by-uuid-36ECD2FDECD2B5F9/NNLK_NEW/ZWOLF_HOME/_Nanalka/new/videos";
COOKIES_FILE="";

# Archives
DEFAULT_ARCHIVE="${SCRIPT_LOCATION}/archive.txt";

# Statistics
NUMBER_OF_URLS="";
TOTAL_TIME="";
ERRORS=0;
SUCCESS=0;
RETRIES=0;

# Disk usage
DISK_SIZE="";
DISK_INITIAL_USE="";
DISK_INITIAL_AVAIL="";
DISK_INITIAL_PERCENT="";
DISK_FINAL_USE="";
DISK_FINAL_AVAIL="";
DISK_FINAL_PERCENT="";

# youtube-dl command output
YT_CMD_OUTPUT="";
YT_CMD_ERROR=0;
YT_CMD_ERROR_MSG="";
RETRY_ERROR_MSG="ERROR: unable to download video data: <urlopen error [Errno -2] Name or service not known>";

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

function dlvStatus() {
    process=$(ps aux | grep -e "sudo python3 /usr/bin/youtube-dl" | grep -v "grep");
    isYtdlRuning="NO";

    if [[ "" != ${process} ]]
    then
        isYtdlRuning="YES";
    fi

    latest_log=$(ls -t ${SCRIPT_LOCATION}/logs/*.log | head -n 1);
    latest_txt=$(ls -t ${SCRIPT_LOCATION}/logs/*.txt | head -n 1);
    latest_err=$(ls -t ${SCRIPT_LOCATION}/logs/*.err | head -n 1);

    echo "Is youtube-dl running: ${isYtdlRuning}";
    echo -e "\n";
    echo "Latest LOG file: ${latest_log}";
    echo "### LOG ###";
    tail -n 30 ${latest_log};
    echo "### LOG ###";
    echo -e "\n";
    echo "Latest TXT file: ${latest_txt}";
    echo "### TXT ###";
    tail ${latest_txt};
    echo "### TXT ###";
    echo -e "\n";
    echo "Latest ERR file: ${latest_err}";
    echo "### ERR ###";
    tail ${latest_err};
    echo "### ERR ###";
}

#
# Sets variables and performs input parameter validations
#
function initScript() {

    # Getting input parameters
    while getopts 'i:o:c:v:s' option
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
            s) dlvStatus;
               exit 0;
               ;;
            ?) printUsage;
               exit 1;
               ;;
        esac
    done
    shift "$(($OPTIND - 1))"

    # Input file validation
    if [[ ! -f ${INPUT_FILE} ]]
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

function checkInitialDiskState() {
    DF_OUTPUT=($(df -ha ${OUTPUT_FOLDER} | tail -n 1 | awk '{print $2,$3,$4,$5}'));

    DISK_SIZE="${DF_OUTPUT[0]}";
    DISK_INITIAL_USE="${DF_OUTPUT[1]}";
    DISK_INITIAL_AVAIL="${DF_OUTPUT[2]}";
    DISK_INITIAL_PERCENT="${DF_OUTPUT[3]}";
}

function checkFinalDiskState() {
    DF_OUTPUT=($(df -ha ${OUTPUT_FOLDER} | tail -n 1 | awk '{print $3,$4,$5}'));

    DISK_FINAL_USE="${DF_OUTPUT[0]}";
    DISK_FINAL_AVAIL="${DF_OUTPUT[1]}";
    DISK_FINAL_PERCENT="${DF_OUTPUT[2]}";
}

function runYoutubeDl() {
    MY_URL=$1;
    ARCHIVE_PARAM="${DEFAULT_ARCHIVE}";
    OUTPUT_PARAM="${OUTPUT_FOLDER}/%(extractor)s/%(title)s - %(id)s.%(ext)s";

    # Checking if there is a cookie file
    cookies_parameter="";
    if [[ "${COOKIES_FILE}" != "" ]]
    then
        verbose "Using cookies: ${COOKIES_FILE}";
        cookies_parameter="--cookies ${COOKIES_FILE}";
    fi

    # Executing youtube-dl and saving the output in YT_CMD_OUTPUT variable
    YT_CMD_OUTPUT=$(sudo python3 /usr/bin/youtube-dl --format 'best[ext=mp4]/best' --no-overwrites --no-progress --restrict-filenames --recode-video mp4 --write-info-json --write-thumbnail --output "${OUTPUT_PARAM}" --download-archive "${ARCHIVE_PARAM}" ${cookies_parameter} "${MY_URL}" 2>&1);

    # Creating an array out from YT_CMD_OUTPUT
    OIFS=${IFS};
    IFS=$'\n';
    OUTPUT_ARRAY=(${YT_CMD_OUTPUT});
    IFS=${OIFS};

    for output_line in "${OUTPUT_ARRAY[@]}"
    do
        logInfo "  ${output_line}";
    done

    # Determine if any error happened
    LAST_LINE=$(echo ${YT_CMD_OUTPUT##*$'\n'}); # Removing the longest match till \n
    if [[ ${LAST_LINE} == *"ERROR"* ]]
    then
        YT_CMD_ERROR=1;
        YT_CMD_ERROR_MSG="${LAST_LINE}";
    else
        YT_CMD_ERROR=0;
        YT_CMD_ERROR_MSG="";
    fi
}

function downloadVideos() {
    start=`date "+%s"`;
    counter=0;

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

        runYoutubeDl "${URL}";

        if [[ !${YT_CMD_ERROR} -eq 0 ]]
        then
            ((ERRORS++));
            logError "An error ocurred while downloading video: '${URL}'";
            logError "${YT_CMD_ERROR_MSG}";
            echo ${URL} >> ${SCRIPT_ERRORFILE};

            CURRENT_RETRIES=0;
            while [[ "${YT_CMD_ERROR_MSG}" == *"${RETRY_ERROR_MSG}"* ]]
            do
                ((CURRENT_RETRIES++));
                logInfo "Retrying (${counter} / ${NUMBER_OF_URLS}) '${URL}' in 30s...";
                sleep 30s;
                logInfo "Retry attempt: ${CURRENT_RETRIES}";
                runYoutubeDl "${URL}";
            done

            ((RETRIES+=CURRENT_RETRIES));
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

    logInfo " ";
    logInfo "-----------------------------------------------";
    logInfo "SUMMARY";
    logInfo "-----------------------------------------------";
    logInfo "Input URLs:     ${NUMBER_OF_URLS}";
    logInfo "Output folder:  ${OUTPUT_FOLDER}";
    logInfo "-----------------------------------------------";
    logInfo "Success:        ${SUCCESS}";
    if [[ !${ERRORS} -eq 0 ]]
    then
        logInfo "Errors:         ${ERRORS}";
    fi
    if [[ !${RETRIES} -eq 0 ]]
    then
        logInfo "Retries:        ${RETRIES}";
    fi
    logInfo "-----------------------------------------------";
    logInfo "Input backup:   ${INPUT_FILE_BACKUP}";
    logInfo "Log File:       ${SCRIPT_LOGFILE}";
    if [[ !${ERRORS} -eq 0 ]]
    then
        logInfo "Errors File:    ${SCRIPT_ERRORFILE}";
    fi
    logInfo "-----------------------------------------------";
    logInfo "Disk size:      ${DISK_SIZE}";
    logInfo "Initial Disk Usage";
    logInfo "  Available:    ${DISK_INITIAL_AVAIL}";
    logInfo "  Used:         ${DISK_INITIAL_USE}";
    logInfo "  Used (%):     ${DISK_INITIAL_PERCENT}";
    logInfo "Final Disk Usage";
    logInfo "  Available:    ${DISK_FINAL_AVAIL}";
    logInfo "  Used:         ${DISK_FINAL_USE}";
    logInfo "  Used (%):     ${DISK_FINAL_PERCENT}";
    logInfo "-----------------------------------------------";
    logInfo "Total time:     ${totalTime}";
    logInfo "-----------------------------------------------";
}

################################################

# Main

initScript $@;
checkInitialDiskState;
downloadVideos;
checkFinalDiskState;
printSummary;
