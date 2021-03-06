PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;

CREATE TABLE assets (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  btc_value REAL NOT NULL,
  rate REAL NOT NULL,
  created_at TEXT NOT NULL,
  active INTEGER NOT NULL
);

CREATE TABLE asset_histories (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  asset_id INTEGER NOT NULL,
  rate REAL NOT NULL,
  created_at TEXT NOT NULL
);

CREATE TABLE trades (
  id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
  asset_id INTEGER NOT NULL,
  trade_type TEXT NOT NULL,
  btc_value REAL NOT NULL,
  rate REAL NOT NULL,
  win REAL,
  created_at TEXT NOT NULL
);

COMMIT;
