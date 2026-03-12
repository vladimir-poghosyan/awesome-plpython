#!/bin/bash

set -eu -o pipefail


psql --username postgres <<-EOSQL
CREATE DATABASE "pgawesome";
CREATE USER pgawesome WITH PASSWORD 'pgawesome';
GRANT ALL PRIVILEGES ON DATABASE pgawesome to pgawesome;

ALTER USER pgawesome WITH SUPERUSER;
EOSQL

psql --username pgawesome --dbname pgawesome <<-EOSQL
CREATE EXTENSION IF NOT EXISTS plpgsql;
COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';

CREATE EXTENSION IF NOT EXISTS plpython3u WITH SCHEMA pg_catalog;
COMMENT ON EXTENSION plpython3u IS 'PL/Python procedural language';
EOSQL
