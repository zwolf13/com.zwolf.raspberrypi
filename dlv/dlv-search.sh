NNLK_VIDEOS=/srv/dev-disk-by-uuid-80D6FAD7D6FACC82/NNLK_SSD/ZWOLF_HOME/_Nanalka/media/videos
NNLK_NEW_VIDEOS=/srv/dev-disk-by-uuid-4E301C2E301C200F/NNLK_SSD_NEW/ZWOLF_HOME/_Nanalka/new/videos

QUERY="${1}";

find "${NNLK_VIDEOS}" "${NNLK_NEW_VIDEOS}" -iname "*${QUERY}*"
