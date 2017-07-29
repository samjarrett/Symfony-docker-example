#!/bin/sh

if [ "$1" == php-fpm ]; then
    set -e

    if [ "$SYMFONY_ENV" == "dev" ]; then
        composer dump-autoload
    fi

    dockerize -wait tcp://${DATABASE_HOST}:${DATABASE_PORT:-3306} -timeout 120s

    su -s /bin/sh \
       -c "bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration" \
       www-data
fi

exec "$@"