for my_file in `ls /home/pi/youtube-dl/yt-meta/json/*.json`
do
#    echo "moving: ${my_file}";
    sudo cp "${my_file}" /home/pi/rpi4mediaserver/nnlk-tmp/yt-metadata
done
