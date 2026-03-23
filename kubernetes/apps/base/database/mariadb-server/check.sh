#!/bin/bash -ec

password_aux="${MYSQL_ROOT_PASSWORD:-}"
if [[ -f "${MYSQL_ROOT_PASSWORD_FILE:-}" ]]; then
    password_aux=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
fi
mariadb-admin status -uroot -p"${password_aux}"
