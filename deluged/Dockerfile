ARG LOCALE=en_US.UTF-8

FROM crazymanjinn/deluge-base as builder
ARG LOCALE
ENV LANG=${LOCALE}
ENV DEBIAN_FRONTEND=noninteractive

RUN printf "=== install packages ===\n" && \
	apt-get update && apt-get install -y \
		python3 \
		python3-pip \
		python3-venv

RUN printf "=== building ===\n" && \
	python3 -m venv --system-site-packages /app && \
	cd /app && \
	. bin/activate  && \
	pip3 install deluge


FROM crazymanjinn/deluge-base as stage2
ARG LOCALE
ENV LANG=${LOCALE}
ENV DEBIAN_FRONTEND=noninteractive

RUN printf "=== install packages ===\n" && \
	apt-get update && apt-get install -y netcat-traditional && \
	printf "=== cleanup ===\n" && rm -rf \
		/tmp/* \
		/var/lib/apt/lists/* \
		/var/tmp/*
ENV DEBIAN_FRONTEND=""

COPY --from=builder /app /app
COPY root/ /

ENV PYTHON_EGG_CACHE="/config/plugins/.python-eggs"
ENV VIRTUAL_ENV=/app
ENV PATH="$VIRTUAL_ENV/bin:$PATH"

ENV LOGLEVEL=info
ENV LISTEN_PORTS=58479

ENTRYPOINT ["/entrypoint.sh"]
EXPOSE 58846 ${LISTEN_PORTS} ${LISTEN_PORTS}/udp
VOLUME /config

HEALTHCHECK CMD ["/bin/netcat", "-z", "127.0.0.1", "58846"]
