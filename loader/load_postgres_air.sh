#!/usr/bin/env bash
set -euo pipefail

: "${POSTGRES_HOST:=db}"
: "${POSTGRES_PORT:=5432}"
: "${POSTGRES_DB:=postgres_air}"
: "${POSTGRES_USER:=postgres}"
: "${POSTGRES_PASSWORD:=postgres}"
: "${POSTGRES_AIR_DUMP_URL:=https://drive.google.com/uc?export=download&id=1C7PVxeYvLDr6n_7qjdA2k0vahv__jMEo}"

export PGPASSWORD="$POSTGRES_PASSWORD"

echo "Waiting for Postgres at ${POSTGRES_HOST}:${POSTGRES_PORT}..."
until pg_isready -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" >/dev/null 2>&1; do
  sleep 3
done
echo "Postgres is ready."

# Проверяем, не развернули ли мы уже схему postgres_air
echo "Checking if schema 'postgres_air' already exists..."
if psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -tAc "SELECT 1 FROM information_schema.schemata WHERE schema_name = 'postgres_air'" | grep -q 1; then
  echo "Schema 'postgres_air' already exists, skipping restore."
  exit 0
fi

echo "Downloading postgres_air dump from ${POSTGRES_AIR_DUMP_URL} ..."
# Извлекаем ID файла из URL
FILE_ID=$(echo "$POSTGRES_AIR_DUMP_URL" | sed -n 's/.*id=\([^&]*\).*/\1/p')
# Используем gdown для надежного скачивания с Google Drive
gdown "https://drive.google.com/uc?id=${FILE_ID}" -O /tmp/postgres_air_2024.sql.zip

echo "Unzipping dump..."
# -p выводит содержимое архива в stdout — не важно, как называется файл внутри
unzip -p /tmp/postgres_air_2024.sql.zip > /tmp/postgres_air_2024.sql

echo "Restoring into database ${POSTGRES_DB}..."
psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" \
  -v ON_ERROR_STOP=1 \
  -f /tmp/postgres_air_2024.sql

echo "Restore finished successfully."
