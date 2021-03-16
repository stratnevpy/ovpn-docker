FROM debian:10
MAINTAINER Pavel Stratnev
WORKDIR /etc/openvpn

COPY init/.const init/
COPY init/main.sh init/
COPY init/pki-config.sh init/
COPY init/server-config.sh init/
COPY init/client-config.sh init/
COPY init/iptables-config.sh init/
COPY init/logrotate-config.sh init/
COPY init/permissions.rb bin/
COPY init/make_user.sh bin/
COPY init/revoke_user.sh bin/
COPY init/update_crl.sh bin/

RUN apt update && apt install wget gnupg tar cron logrotate iptables ruby python -y && \
    wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - && \
    echo "deb http://build.openvpn.net/debian/openvpn/stable buster main" > /etc/apt/sources.list.d/openvpn.list && \
    apt update && apt install openvpn -y && \
    wget -P /tmp https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz && \ 
    tar xfv /tmp/EasyRSA-3.0.8.tgz -C /tmp >> /dev/null

#- clean
RUN apt remove --purge tar gnupg wget && apt autoremove
RUN rm /tmp/Easy* /var/cache/apt/* -r

EXPOSE 1194/udp

ENTRYPOINT [ "init/main.sh" ]
CMD [ ]
