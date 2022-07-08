#!/bin/bash

NNLK_NEW_VIDEOS=/srv/dev-disk-by-uuid-FE5A2CD05A2C880B/NNLK_NEW/ZWOLF_HOME/_Nanalka/new/videos;
NNLK_ONLINE_VIDEOS=/srv/dev-disk-by-uuid-A8500FA4500F7878/ZWOLF_HOME/_Nanalka/media/videos;

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
    echo "${line/*dev-disk-by-uuid-A8500FA4500F7878/NNLK_ONLINE}";
done
