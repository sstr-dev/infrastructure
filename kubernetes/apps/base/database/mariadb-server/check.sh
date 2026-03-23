#!/bin/bash -ec

password_args=()
if [[ "${MARIADB_HEALTHCHECK_USE_PASSWORD:-false}" == "true" ]]; then
    password_aux="${MYSQL_ROOT_PASSWORD:-}"
    if [[ -f "${MYSQL_ROOT_PASSWORD_FILE:-}" ]]; then
        password_aux=$(cat "$MYSQL_ROOT_PASSWORD_FILE")
    fi
    password_args=(-p"${password_aux}")
fi

mariadb-admin status -uroot "${password_args[@]}"
