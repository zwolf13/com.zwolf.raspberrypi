import mariadb;
import json;
import sys;
import glob;
import os;

# Connecting to MariaDB
try:
    connection = mariadb.connect(
        user="dbuser",
        password="1391313913",
        host="localhost",
        port=3306,
        database="nnlk_test_db"
    );
except mariadb.Error as e:
    print(f"Error connecting to MariaDB: {e}");
    sys.exit(1);

cursor = connection.cursor();

# Reading all the JSON files in the folder
BASE_PATH="/home/pi/rpi4-online-nnlk_online/media/videos/afreecatv";
os.chdir(BASE_PATH);
for my_file in glob.glob("*20201214_2728D4A2_229303123_4.info.json"):
    print(f"Working on {my_file}...");

    with open(f"{BASE_PATH}/{my_file}") as json_file:
        # Deserializing .json file
        data = json.load(json_file);

        # Reading JSON properties
        id = data.get("id");
        extractor = data.get("extractor");
        extractor_key = data.get("extractor_key");
        channel_id = data.get("channel_id");
        channel_url = data.get("channel_url");
        comments = data.get("comments");
        description = data.get("description");
        display_id = data.get("display_id");
        duration = data.get("duration");
        title = data.get("title");
        fulltitle = data.get("fulltitle");
        tags = data.get("tags");
        fixed_tags = ",".join(tags) if tags is not None else None;
        thumbnail = data.get("thumbnail");
        ytdl_timestamp = data.get('timestamp');
        upload_date = data.get("upload_date");
        uploader = data.get("uploader");
        uploader_id = data.get("uploader_id");
        uploader_url = data.get("uploader_url");
        webpage_url = data.get("webpage_url");
        webpage_url_basename = data.get("webpage_url_basename");
        url = data.get("url");
        height = data.get("height");
        width = data.get("width");

        try:
            cursor.execute(
                "INSERT INTO nnlk_metadata(id, extractor, extractor_key, channel_id, channel_url, comments, description, display_id, duration, title, fulltitle, tags, thumbnail, ytdl_timestamp, upload_date, uploader, uploader_id, uploader_url, webpage_url, webpage_url_basename, url, height, width, json) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
                (id, extractor, extractor_key, channel_id, channel_url, comments, description, display_id, duration, title, fulltitle, tags, thumbnail, ytdl_timestamp, upload_date, uploader, uploader_id, uploader_url, webpage_url, webpage_url_basename, url, height, width, json.dumps(data))
            );
            connection.commit();
        except mariadb.Error as e:
            print(f"Error with id {id}: {e}");
            sys.exit(1);

connection.close();
