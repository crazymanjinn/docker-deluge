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


initial_sleep=0.25
declare -i tries=1

until [[ -e /config/.initialized ]]; do
	if ((tries > ${RETRIES:-3})); then
		printf "deluged did not initialize after %d attempts\n" "$tries" 1>&2
		exit 1
	fi

	sleep $initial_sleep

	((tries ++))
	initial_sleep=$(bc <<< "$initial_sleep * 2")
done

printf "url = 127.0.0.1:%s\n" "${PORT:-8112}" >> /health.cfg

CMD=(
	"/app/bin/deluge-web"
	"--config" "/config"
	"--do-not-daemonize"
	"--port" "${PORT:-8112}"
	"--loglevel" "${LOGLEVEL:-info}"
)
export HOME=${HOME:-/home/app}
exec setpriv --reuid app --regid app --init-groups "${CMD[@]}"
