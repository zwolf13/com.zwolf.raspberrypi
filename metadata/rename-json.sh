#!/bin/bash

OIFS=${IFS};
IFS=$'\r\n';
yt_videos=(`cat /home/pi/rpi4-online-nnlk_online/youtube.files.txt`);
IFS=${OIFS};

for json_fullpath in /home/pi/rpi4-online-nnlk_online/media/yt-metadata/*
do
    # json_fullpath: /home/pi/rpi4-online-nnlk_online/media/yt-metadata/00ydSWSL_Eg.json
    json_filename=${json_fullpath##*/}; # 00ydSWSL_Eg.json
    json_id=${json_filename%.json};     # 00ydSWSL_Eg
    yt_video_path="";

    for yt_video in "${yt_videos[@]}"
    do
        if [[ "${yt_video}" == *"${json_id}"* ]]
        then
            yt_video_path="${yt_video}";
            break;
        fi
    done

    if [[ "${yt_video_path}" == "" ]]
    then
        echo "${json_id}" >> ~/git/com.zwolf.raspberrypi/utils/yt-meta/names-not-found.txt
        continue;
    fi

    # yt_video_path: youtube/p/Pam snoring lol - 00ydSWSL_Eg.mp4
    yt_video_filename="${yt_video_path##*/}";         # Pam snoring lol - 00ydSWSL_Eg.mp4
    yt_video_name="${yt_video_filename%.*}";          # Pam snoring lol - 00ydSWSL_Eg

    json_new_filename="${yt_video_name}.info.json";   # Pam snoring lol - 00ydSWSL_Eg.info.json
    json_new_path=${yt_video_path%/*};                # youtube/p

    # /home/pi/rpi4-online-nnlk_online/media/metadata/youtube/p/Pam snoring lol - 00ydSWSL_Eg.info.json
    json_new_fullpath="/home/pi/rpi4-online-nnlk_online/media/metadata/${json_new_path}/${json_new_filename}";

    echo "Moving '${json_fullpath}' to '${json_new_fullpath}'..."
    sudo mv "${json_fullpath}" "${json_new_fullpath}";
done
