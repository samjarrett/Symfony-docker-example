#!/bin/sh

if [ "$1" == php-fpm ]; then
    set -e

    su -s /bin/sh \
       -c "bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration" \
       www-data
fi

exec "$@"