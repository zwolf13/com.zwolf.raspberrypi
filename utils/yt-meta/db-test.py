import mariadb
import sys

# Connecting to MariaDB
try:
    connection = mariadb.connect(
        user="dbuser",
        password="1391313913",
        host="localhost",
        port=3306,
        database="nnlk_test_db"
    )
except mariadb.Error as e:
    print(f"Error connecting to MariaDB: {e}")
    sys.exit(1)

cursor = connection.cursor()
cursor.execute("SELECT id, extractor, extractor_key, channel_id, channel_url FROM nnlk_metadata")
for (id, extractor, extractor_key, channel_id, channel_url) in cursor:
    print(f"id: {id}, extractor: {extractor}, extractor_key: {extractor_key}, channel_id: {channel_id}, channel_url: {channel_url}")
