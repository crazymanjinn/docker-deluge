ARG BASE_VERSION=10-slim

FROM debian:${BASE_VERSION} as builder
ENV DEBIAN_FRONTEND=noninteractive

RUN printf "=== install packages ===\n" && \
	apt-get update && apt-get install -y --no-install-recommends \
		python3 \
		python3-chardet \
		python3-mako \
		python3-pil \
		python3-pip \
		python3-pyasn1 \
		python3-rencode \
		python3-setproctitle \
		python3-six \
		python3-twisted \
		python3-venv  \
		python3-zope.interface

RUN printf "=== building ===\n" && \
	python3 -m venv --system-site-packages /app && \
	cd /app && \
	. bin/activate  && \
	pip3 install deluge

FROM debian:${BASE_VERSION}
ENV DEBIAN_FRONTEND=noninteractive

RUN printf "=== install packages ===\n" && \
	apt-get update && apt-get install --no-install-recommends -y \
		ca-certificates \
		netcat-traditional \
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
	printf "=== cleanup ===\n" && \
	rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*

COPY --from=builder /app /app
COPY root/ /

ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"
ENV VIRTUAL_ENV=/app
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV LISTEN_PORTS=58479

ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 58846 58479 58479/udp
VOLUME /config /download

HEALTHCHECK ["/bin/netcat", "-z", "127.0.0.1", "58479"]
