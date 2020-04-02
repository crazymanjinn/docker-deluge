ARG BASE_VERSION=10-slim
ARG LOCALE=en_US.UTF-8

FROM debian:${BASE_VERSION} as locale
ARG LOCALE
ENV DEBIAN_FRONTEND=noninteractive

RUN printf '=== setting locale %s ===\n' ${LOCALE} && \
	apt-get update && \
	apt-get install -y locales && \
	sed -i "s/^# ${LOCALE}/${LOCALE}/" /etc/locale.gen && \
	locale-gen


FROM debian:${BASE_VERSION} as builder
ARG LOCALE
ENV DEBIAN_FRONTEND=noninteractive

COPY --from=locale /usr/lib/locale/locale-archive /usr/lib/locale/locale-archive
ENV LANG=${LOCALE}

RUN printf '=== disabling recommends ===\n' && \
	printf 'APT::Install-Recommends "0";\n' > /etc/apt/apt.conf.d/docker-no-recommends

RUN printf '=== installing packages ===\n' && \
	apt-get update && \
	apt-get install -y \
		ca-certificates \
		python3-chardet \
		python3-libtorrent \
		python3-mako \
		python3-minimal \
		python3-pil \
		python3-pyasn1 \
		python3-rencode \
		python3-setproctitle \
		python3-six \
		python3-twisted \
		python3-zope.interface \
	&& \
	printf '=== cleanup ===\n' && \
	rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

FROM scratch
ARG LOCALE
ENV LANG=${LOCALE}
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV TERM=xterm

COPY --from=builder / /
CMD ["bash"]
