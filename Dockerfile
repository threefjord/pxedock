FROM alpine:3.6

# How often to check the hostlist for updates, default DNS, defaut pxeboot, IP
ENV DHCP_update_time=60 DNS="8.8.8.8" PXE_target="netboot.xyz.kpxe" IP=

LABEL version="0.4" \
      description="A dockerized dchp+tftp server,\
for serving PXE-bootable images"

ADD https://boot.netboot.xyz/ipxe/netboot.xyz.kpxe /tftpboot/

# http://forum.alpinelinux.org/apk/main/x86_64/tftp-hpa
RUN apk add --no-cache tftp-hpa dhcp && \
    touch /var/lib/dhcp/dhcpd.leases && \
    adduser -D tftp

# Do not track further change to /tftpboot or the dhcp conf directory
VOLUME /tftpboot /etc/dhcp/conf.d

EXPOSE 69/udp 67/udp 67/tcp

# copy in our starter-file (starts dhcp & tftpd)
COPY ["start", "auto-dhcp", "/usr/sbin/"]

ENTRYPOINT ["/usr/sbin/start"]

CMD ["-L", "--verbose", "-u", "tftp", "--secure", "/tftpboot"]

