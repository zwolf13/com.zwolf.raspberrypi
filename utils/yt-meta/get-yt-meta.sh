#!/bin/bash

INPUT_FILE=missing-db-ids.txt
TOTAL_IDS=`cat ${INPUT_FILE} | wc -l`;

counter=0;
while read ytid
do
    ((counter++));
    echo "[${counter} / ${TOTAL_IDS}] Working on '${ytid}'...";
    OUTPUT=json/${ytid}.json;

    python3 /usr/bin/youtube-dl --dump-json --cookies cookies.txt "https://youtu.be/${ytid}" | python -m json.tool > ${OUTPUT};

    if [ $? -eq 0 ]
    then
        chmod 777 ${OUTPUT}
        echo ${ytid} >> success.log
    else
        echo "ERROR with '${ytid}'!";
        echo ${ytid} >> error.log
        rm -f ${OUTPUT}
    fi
done < ${INPUT_FILE}
