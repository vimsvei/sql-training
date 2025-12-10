#!/bin/bash
# Скрипт для добавления сервера в pgAdmin через API

set -e

PGADMIN_URL="${PGADMIN_URL:-http://pgadmin:80}"
EMAIL="${PGADMIN_EMAIL:-admin@example.com}"
PASSWORD="${PGADMIN_PASSWORD:-admin}"

# Ждем, пока pgAdmin запустится
echo "Waiting for pgAdmin to be ready..."
for i in {1..30}; do
    if curl -s -f "${PGADMIN_URL}/misc/ping" > /dev/null 2>&1; then
        echo "pgAdmin is ready!"
        break
    fi
    echo "Attempt $i/30: pgAdmin not ready yet, waiting..."
    sleep 2
done

# Получаем CSRF токен и сессию
echo "Logging in to pgAdmin..."
LOGIN_RESPONSE=$(curl -s -c /tmp/pgadmin_cookies.txt -b /tmp/pgadmin_cookies.txt \
    -X POST "${PGADMIN_URL}/authenticate/login" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "email=${EMAIL}&password=${PASSWORD}")

# Проверяем, есть ли уже сервер
echo "Checking for existing servers..."
EXISTING_SERVERS=$(curl -s -b /tmp/pgadmin_cookies.txt \
    "${PGADMIN_URL}/browser/server_group/children/1" \
    -H "X-pgA-CSRFToken: $(grep csrftoken /tmp/pgadmin_cookies.txt | awk '{print $7}')")

if echo "$EXISTING_SERVERS" | grep -q "Postgres Air"; then
    echo "Server 'Postgres Air' already exists, skipping..."
    exit 0
fi

# Получаем CSRF токен для API запросов
CSRF_TOKEN=$(grep csrftoken /tmp/pgadmin_cookies.txt | awk '{print $7}')

# Добавляем сервер
echo "Adding server 'Postgres Air'..."
SERVER_DATA='{
    "name": "Postgres Air",
    "group": 1,
    "host": "db",
    "port": 5432,
    "maintenance_db": "postgres_air",
    "username": "postgres",
    "password": "postgres",
    "ssl_mode": "prefer",
    "comment": "PostgreSQL Air Training Database"
}'

RESPONSE=$(curl -s -w "\n%{http_code}" -b /tmp/pgadmin_cookies.txt \
    -X POST "${PGADMIN_URL}/browser/server/obj/json" \
    -H "Content-Type: application/json" \
    -H "X-pgA-CSRFToken: ${CSRF_TOKEN}" \
    -d "${SERVER_DATA}")

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "201" ]; then
    echo "Server added successfully!"
else
    echo "Failed to add server. HTTP code: $HTTP_CODE"
    echo "Response: $BODY"
    # Пробуем альтернативный endpoint
    echo "Trying alternative method..."
    curl -s -b /tmp/pgadmin_cookies.txt \
        -X POST "${PGADMIN_URL}/browser/server/" \
        -H "Content-Type: application/json" \
        -H "X-pgA-CSRFToken: ${CSRF_TOKEN}" \
        -d "${SERVER_DATA}"
fi

echo ""
echo "Server 'Postgres Air' has been added successfully!"
