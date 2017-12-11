FROM ubuntu

ARG TZ='Asia/Shanghai'

ENV TZ $TZ

RUN apt-get update -y \
    && apt-get install -y bash tzdata iptables net-tools bash\
        git \
        curl \
    && curl -sSLO https://github.com/koolshare/ledesoft/blob/master/sgame/sgame/bin/tinyvpn \
    && curl -sSLO https://github.com/koolshare/ledesoft/blob/master/sgame/sgame/bin/udp2raw \
    && mv tinyvpn /usr/bin/tinyvpn \
    && mv udp2raw /usr/bin/udp2raw \
    && ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone \


ADD entrypoint.sh /entrypoint.sh
ADD tinyvpn.sh /tinyvpn.sh
RUN chmod +x /entrypoint.sh
RUN chmod +x /tinyvpn.sh
RUN chmod +x /usr/bin/tinyvpn
RUN chmod +x /usr/bin/udp2raw

ENTRYPOINT ["/entrypoint.sh"]
