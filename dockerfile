FROM debian:10.8
MAINTAINER Pavel Stratnev
WORKDIR /etc/openvpn

COPY init .
COPY bin .

RUN chmod -R +x init bin

RUN apt update && apt install -y \ 
        wget \
        gnupg \
        tar \
        iptables \
        ruby \
        python
RUN wget -O - https://swupdate.openvpn.net/repos/repo-public.gpg | apt-key add - && \
    echo "deb http://build.openvpn.net/debian/openvpn/stable buster main" > /etc/apt/sources.list.d/openvpn.list && \
    wget -P /tmp https://github.com/OpenVPN/easy-rsa/releases/download/v3.0.8/EasyRSA-3.0.8.tgz && \ 
    tar -xf /tmp/EasyRSA-3.0.8.tgz -C /tmp > /dev/null
RUN apt update && apt install openvpn -y

#- clean
RUN apt remove --purge tar gnupg wget && apt autoremove
RUN rm /tmp/Easy* /var/cache/apt/* -r

EXPOSE 1194/udp

ENTRYPOINT [ "init/main.sh" ]
CMD [ ]
