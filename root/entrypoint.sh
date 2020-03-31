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
	"--loglevel" "${DELUGE_LOGLEVEL:-info}"
)

if [[ ! -e /config/.initialized ]]; then
	timeout -s INT 1 "${CMD[@]}" || true

	pushd /config
	grep -q '^admin' auth ||
		printf "admin:%s:10\n" "${DEFAULT_PASS:-admin}" >> auth
	sed -i -e '/allow_remote/s/false/true/' core.conf
	touch .initialized
	popd

	chown -R app:app /config
fi

exec chroot --userspec app:app / "${CMD[@]}"
