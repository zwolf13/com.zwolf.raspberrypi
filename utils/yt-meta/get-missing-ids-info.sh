OIFS=${IFS};
IFS=$'\n';
file_info_array=(`cat yt-files.txt`);

while read ytid
do
    for file_info in "${file_info_array[@]}"
    do
        if [[ ${file_info} == *"${ytid}"* ]]
        then
            echo "${ytid}, ${file_info}";
        fi
    done
done < missing-db-ids.txt
