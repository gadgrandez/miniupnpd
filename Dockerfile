FROM	alpine:latest

RUN	apk add miniupnpd util-linux && \
	echo \#\!/bin/sh >> /usr/local/bin/entrypoint.sh && \
	echo "/sbin/iptables -t nat -F MINIUPNPD && /sbin/iptables -t nat -X MINIUPNPD" >> /usr/local/bin/entrypoint.sh && \
	echo "/sbin/iptables -F MINIUPNPD && /sbin/iptables -X MINIUPNPD" >> /usr/local/bin/entrypoint.sh && \
	echo "/sbin/iptables -t nat -N MINIUPNPD && /sbin/iptables -N MINIUPNPD" >> /usr/local/bin/entrypoint.sh && \
	echo "miniupnpd \"\$@\"" >> /usr/local/bin/entrypoint.sh && \
	chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]
CMD	["-d"]
