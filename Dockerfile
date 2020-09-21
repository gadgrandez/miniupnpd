FROM	alpine:latest

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
ENV MINISSDPD_IF=eth1

RUN	apk add miniupnpd minissdpd util-linux && \
	chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
