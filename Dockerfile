FROM alpine:3.6

ARG TZ='Asia/Shanghai'

ENV TZ $TZ

RUN apk upgrade --update \
    && apk add bash tzdata iptables net-tools bash\
    && apk add --virtual .build-deps \
        git \
        curl \
    && curl -sSLO https://github.com/koolshare/ledesoft/blob/master/sgame/sgame/bin/tinyvpn \
    && curl -sSLO https://github.com/koolshare/ledesoft/blob/master/sgame/sgame/bin/udp2raw \
    && mv tinyvpn /usr/bin/tinyvpn \
    && mv udp2raw /usr/bin/udp2raw \
    && ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \
    && runDeps="$( \
        scanelf --needed --nobanner /usr/bin/ss-* \
            | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
            | xargs -r apk info --installed \
            | sort -u \
        )" \
    && apk add --no-cache --virtual .run-deps $runDeps \
    && apk del .build-deps \
    && rm -rf \
        /var/cache/apk/*

ADD entrypoint.sh /entrypoint.sh
ADD tinyvpn.sh /tinyvpn.sh
RUN chmod +x /entrypoint.sh
RUN chmod +x /tinyvpn.sh
RUN chmod +x /usr/bin/tinyvpn
RUN chmod +x /usr/bin/udp2raw

ENTRYPOINT ["/entrypoint.sh"]
