#!/bin/sh

if [ "$1" == php-fpm ]; then
    set -e

    if [ "$SYMFONY_ENV" == "dev" ]; then
        composer dump-autoload
    fi

    su -s /bin/sh \
       -c "bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration" \
       www-data
fi

exec "$@"