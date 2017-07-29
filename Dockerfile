FROM samjarrett/php-toolkit AS php_dependencies

WORKDIR /source
RUN set -xe && \
    apk add --no-cache --virtual .build-deps git && \
    true

COPY composer.json composer.lock /source/
RUN set -xe && \
    composer install --no-scripts --no-progress --no-suggest --prefer-dist --no-autoloader && \
    true

########################################################################################################################

FROM node:alpine AS node_dependencies

ENV NODE_ENV=production

WORKDIR /source

### If we had a front-end build chain, we would install and compile our assets like this:
#RUN set -xe && \
#    apk add --no-cache --virtual .build-deps git gzip && \
#    true
#
#COPY package.json yarn.lock /source/
#RUN set -xe && \
#    yarn --production && \
#    true
#
#COPY webpack.config.js postcss.config.js .babelrc /source/
#COPY design /source/design
#
#RUN set -xe && \
#    yarn run build && \
#    true

### Instead, just copy some rando files to the web directory to simulate a front-end build
COPY design /source/design
RUN set -xe && \
    mkdir -p web/assets && \
    cp -r design/* web/assets/ && \
    true

########################################################################################################################

FROM samjarrett/php-toolkit

ENV FPM_PROCESS_MANAGER=ondemand \
    PHP_TIMEZONE="Australia/Melbourne" \
    DATABASE_HOST=db

WORKDIR /app

# Bring in installed PHP deps
COPY --from=php_dependencies /source/vendor /app/vendor
COPY --from=php_dependencies /source/composer.json /source/composer.lock /app/

COPY bin /app/bin
COPY web /app/web
COPY src /app/src
COPY app /app/app

RUN set -xe && \
    composer dump-autoload --optimize --classmap-authoritative && \
    mkdir -p var/cache var/logs var/sessions && \
    composer run-script post-install-cmd --no-interaction && \
    chown -R www-data var && \
    rm -rf var/logs/* && \
    true

# Bring in compiled front-end assets
COPY --from=node_dependencies /source/web /app/web
