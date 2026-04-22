-- MySQL schema for Sudoku online
CREATE DATABASE IF NOT EXISTS sudoku CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE sudoku;

CREATE TABLE IF NOT EXISTS users (
  id CHAR(36) PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  salt VARCHAR(64) NOT NULL,
  password_hash VARCHAR(128) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS sessions (
  token CHAR(36) PRIMARY KEY,
  user_id CHAR(36) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  expires_at TIMESTAMP NULL,
  CONSTRAINT fk_sessions_user FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS rooms (
  code VARCHAR(8) PRIMARY KEY,
  difficulty VARCHAR(10) NOT NULL,
  seed BIGINT NOT NULL,
  status VARCHAR(10) NOT NULL, -- waiting|matched|finished
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  host_user_id CHAR(36) NOT NULL,
  guest_user_id CHAR(36) NULL,

  host_last_seen TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  guest_last_seen TIMESTAMP NULL,

  host_lives INT NOT NULL DEFAULT 5,
  guest_lives INT NOT NULL DEFAULT 5,
  host_grid VARCHAR(81) NULL,
  guest_grid VARCHAR(81) NULL,

  host_seconds INT NULL,
  guest_seconds INT NULL,
  host_finished TINYINT(1) NOT NULL DEFAULT 0,
  guest_finished TINYINT(1) NOT NULL DEFAULT 0,
  winner_user_id CHAR(36) NULL,

  CONSTRAINT fk_rooms_host FOREIGN KEY (host_user_id) REFERENCES users(id),
  CONSTRAINT fk_rooms_guest FOREIGN KEY (guest_user_id) REFERENCES users(id),
  CONSTRAINT fk_rooms_winner FOREIGN KEY (winner_user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS match_history (
  room_code VARCHAR(8) PRIMARY KEY,
  difficulty VARCHAR(10) NOT NULL,
  seed BIGINT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ended_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  host_user_id CHAR(36) NOT NULL,
  guest_user_id CHAR(36) NOT NULL,

  host_seconds INT NOT NULL,
  guest_seconds INT NOT NULL,
  host_lives INT NOT NULL,
  guest_lives INT NOT NULL,

  winner_user_id CHAR(36) NOT NULL,
  -- Không dùng FK để tránh lỗi engine/collation khi chạy nhanh trên nhiều môi trường
);

