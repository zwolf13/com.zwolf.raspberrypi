while read video_id
do
    is_mp4_found=`find /home/pi/rpi4mediaserver/nnlk-tmp/videos -type f -name "*${video_id}*.mp4"`;

    if [[ "${is_mp4_found}" != "" ]]
    then
        echo "${video_id} OK";
    else
        echo "${video_id} MISSING";
    fi
done < ${1}
