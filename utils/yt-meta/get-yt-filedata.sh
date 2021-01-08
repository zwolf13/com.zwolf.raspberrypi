#!/bin/bash

# Preparing output files
rm -f yt-files.txt yt-ids.txt yt-duplicated-ids.txt yt-uniq-ids.txt yt-invalid-ids.txt db-ids.txt missing-db-ids.txt
> yt-files.txt
> yt-ids.txt
> yt-duplicated-ids.txt
> yt-uniq-ids.txt
> yt-invalid-ids.txt
> db-ids.txt
> missing-db-ids.txt
chmod 777 yt-files.txt yt-ids.txt yt-duplicated-ids.txt yt-uniq-ids.txt yt-invalid-ids.txt db-ids.txt missing-db-ids.txt

# Getting files data
find /home/pi/zwolf_home/_Nanalka/media/videos/yt -type f > yt-files.txt

# Fixing binary characters
cat -e yt-files.txt | sed 's/\$$//g' > yt-files.tmp

# Getting valid yt-ids
grep -oe "[a-zA-Z0-9_-]\{11\}\.[a-zA-Z0-9]\{3,4\}$" yt-files.tmp > yt-ids.tmp
grep -oe "^[a-zA-Z0-9_-]\{11\}" yt-ids.tmp > yt-ids.txt

# Getting uniq and duplicated yt-ids
cat yt-ids.txt | sort -u > yt-uniq-ids.txt
cat yt-ids.txt | sort | uniq -c | awk '{ if ($1 != 1) print $2 }' > yt-duplicated-ids.txt

# Getting invalid yt-ids
grep -ve "[a-zA-Z0-9_-]\{11\}\.[a-zA-Z0-9]\{3,4\}$" yt-files.tmp > yt-invalid-ids.txt

# Getting db ids
sudo mysql -u dbuser -p1391313913 -h 0.0.0.0 "nnlk_test_db" --skip-column-names -e "SELECT id FROM nnlk_metadata" > db-ids.tmp
cat db-ids.tmp | sort > db-ids.txt
diff yt-uniq-ids.txt db-ids.txt | grep -e "^<" | sed 's/< //g' > missing-db-ids.txt

# Removing temporal files
rm -f yt-ids.tmp
rm -f yt-files.tmp
rm -f db-ids.tmp
