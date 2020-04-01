#!/usr/bin/env bash
[[ -n "$DEBUG" ]] && set -x

set -euo pipefail

umask "${UMASK_SET:-022}"

PUID=${PUID:-911}
PGID=${PGID:-911}
groupadd -g "$PGID" app || groupmod -o -g "$PGID" app
useradd -g "$PGID" -u "$PUID" app ||  usermod -o -u "$PUID" app
export HOME=/home/app

printf -- "---------------------------\n"
printf -- "User uid\t%s\n" "$(id -u app)"
printf -- "User gid\t%s\n" "$(id -g app)"
printf -- "---------------------------\n"
chown -R app:app /config

CMD=(
	"/app/bin/deluged"
	"--config" "/config"
	"--do-not-daemonize"
)

if [[ ! -e /config/.initialized ]]; then
	timeout -s INT 1 "${CMD[@]}" || true

	pushd /config
	if ! [[ -e auth && -e core.conf ]]; then
		printf "deluged failed to initialize\n" 1>&2
		exit 1
	fi
	
	printf "setting default password\n" 1>&2
	grep -q '^admin' auth ||
		printf "admin:%s:10\n" "${DEFAULT_PASS:-admin}" >> auth

	printf "enabling remote access\n" 1>&2
	/update_config.py

	touch .initialized
	popd

	chown -R app:app /config
fi

CMD+=( "--loglevel" "${DELUGE_LOGLEVEL:-info}" )

export HOME=${HOME:-/home/app}
exec setpriv --reuid app --regid app --init-groups "${CMD[@]}"
