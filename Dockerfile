FROM	alpine:latest

RUN	apk add miniupnpd util-linux && \
	echo \#\!/bin/sh >> /usr/local/bin/entrypoint.sh && \
	echo "miniupnpd \"\$@\"" >> /usr/local/bin/entrypoint.sh && \
	chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD	["-d"]
