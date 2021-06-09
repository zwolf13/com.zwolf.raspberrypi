#!/bin/bash

NNLK_NEW_VIDEOS=/srv/dev-disk-by-uuid-36ECD2FDECD2B5F9/NNLK_NEW/ZWOLF_HOME/_Nanalka/new/videos;
NNLK_ONLINE_VIDEOS=/srv/dev-disk-by-uuid-60702DB2702D9038/NNLK_ONLINE/ZWOLF_HOME/_Nanalka/media/videos;

QUERY="${1}";

NEW_RESULTS=$(find ${NNLK_NEW_VIDEOS} -iname "*${QUERY}*");
ONLINE_RESULTS=$(find ${NNLK_ONLINE_VIDEOS} -iname "*${QUERY}*");

# Creating arrays
OIFS=${IFS};
IFS=$'\n';
NEW_RESULTS_ARRAY=(${NEW_RESULTS});
ONLINE_RESULTS_ARRAY=(${ONLINE_RESULTS});
IFS=${OIFS};

for line in "${NEW_RESULTS_ARRAY[@]}"
do
    echo "${line/*NNLK_NEW/NNLK_NEW}";
done

for line in "${ONLINE_RESULTS_ARRAY[@]}"
do
    echo "${line/*NNLK_ONLINE/NNLK_ONLINE}";
done
