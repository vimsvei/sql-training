#!/bin/bash
# Скрипт для добавления доменов pgAdmin в /etc/hosts

HOSTS_FILE="/etc/hosts"
DOMAINS="pgadmin-sql.local pgadmin-sql.localhost"

# Проверяем, не добавлены ли уже домены
if grep -q "pgadmin-sql" "$HOSTS_FILE" 2>/dev/null; then
    echo "Домены pgadmin-sql уже добавлены в $HOSTS_FILE"
    exit 0
fi

echo "Добавление доменов в $HOSTS_FILE..."
echo "Требуются права администратора (sudo)"

# Добавляем записи
sudo sh -c "echo '127.0.0.1 $DOMAINS' >> $HOSTS_FILE"

if [ $? -eq 0 ]; then
    echo "✓ Домены успешно добавлены!"
    echo ""
    echo "Теперь pgAdmin доступен по адресам:"
    echo "  - http://pgadmin-sql.local:8000"
    echo "  - http://pgadmin-sql.localhost:8000"
    echo "  - http://localhost:8000"
else
    echo "✗ Ошибка при добавлении доменов"
    exit 1
fi
