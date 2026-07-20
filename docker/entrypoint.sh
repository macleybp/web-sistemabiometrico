#!/bin/bash
set -e

rm -f /etc/apache2/mods-enabled/mpm_event.*
rm -f /etc/apache2/mods-enabled/mpm_worker.*
a2enmod mpm_prefork 2>/dev/null || true

exec /usr/local/bin/docker-php-entrypoint "$@"
