FROM	alpine:latest

COPY entrypoint.sh /usr/local/bin/entrypoint.sh

RUN	apk add miniupnpd util-linux && \
	chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD	["-d"]
