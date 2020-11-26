DROP DATABASE IF EXISTS wp_db;
CREATE DATABASE wp_db CHARSET utf8mb4;
USE wp_db;

CREATE USER IF NOT EXISTS 'wp_user'@'%';
SET PASSWORD FOR 'wp_user'@'%' = 'wp_pass';
GRANT ALL PRIVILEGES ON wp_db.* TO 'wp_user'@'%';