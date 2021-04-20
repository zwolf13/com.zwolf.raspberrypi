INPUT_FILE="cut.txt";

while read ENTRY
do
    FILE=${ENTRY%,*};

    echo "Working on file: ${FILE}...";

    OIFS=$IFS;
    IFS="|";
    RANGES=(${ENTRY#*,});
    IFS=$OIFS;

    for (( index=0; index<${#RANGES[@]}; index++ ));
    do
        range=${RANGES[index]};
        start=${range%;*};
        end=${range#*;};
        ext=${FILE##*.};
        filename="${FILE%.*} - ${index}.${ext}";

        echo "Cutting range from ${start} to ${end}...";
        ffmpeg -n -hide_banner -loglevel quiet  -i "${FILE}" -ss "${start}" -to "${end}" -c:v copy -c:a copy "${filename}"
    done

done < ${INPUT_FILE}
