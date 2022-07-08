DROP DATABASE IF EXISTS nnlk_test_db;

CREATE DATABASE nnlk_test_db
    CHARACTER SET = 'utf8mb4' -- 'utf8'
;

USE nnlk_test_db;

CREATE OR REPLACE TABLE nnlk_metadata(
--  categories
--  ext
--  _filename
--  formats
--  thumbnails
    id VARCHAR(32),
    extractor VARCHAR(32),
    extractor_key VARCHAR(32),
    channel_id VARCHAR(256),
    channel_url VARCHAR(256),
    comments VARCHAR(512),
    description MEDIUMTEXT,
    display_id VARCHAR(32),
    duration INT,
    title VARCHAR(256),
    fulltitle VARCHAR(256),
    tags VARCHAR(256),
    thumbnail VARCHAR(256),
    ytdl_timestamp INT,
    upload_date VARCHAR(8),
    uploader VARCHAR(64),
    uploader_id VARCHAR(32),
    uploader_url VARCHAR(64),
    webpage_url VARCHAR(256),
    webpage_url_basename VARCHAR(256),
    url VARCHAR(1024),
    height INT,
    width INT,
    json MEDIUMTEXT
);

