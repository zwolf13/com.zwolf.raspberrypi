NNLK_NEW_VIDEOS=/srv/dev-disk-by-uuid-36ECD2FDECD2B5F9/NNLK_NEW/ZWOLF_HOME/_Nanalka/new/videos
NNLK_ONLINE_VIDEOS=/srv/dev-disk-by-uuid-60702DB2702D9038/NNLK_ONLINE/ZWOLF_HOME/_Nanalka/media/videos

QUERY="${1}";

find "${NNLK_NEW_VIDEOS}" "${NNLK_ONLINE_VIDEOS}" -iname "*${QUERY}*"
