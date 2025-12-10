#!/bin/bash
set -e

# Если файл servers.json существует и база данных еще не инициализирована, копируем его
if [ -f /pgadmin4/servers.json ] && [ ! -f /var/lib/pgadmin/storage/admin_example.com/pgadmin4.db ]; then
    echo "Copying servers.json for initial import..."
    mkdir -p /var/lib/pgadmin/storage/admin_example.com
    cp /pgadmin4/servers.json /var/lib/pgadmin/storage/admin_example.com/servers.json
fi

# Запускаем оригинальный entrypoint
exec /entrypoint.sh "$@"
