FROM alpine:3.6

# How often to check the hostlist for updates, and a default DNS
ENV DHCP_update_time=60 DNS="8.8.8.8"

LABEL version="0.4" \
      description="A dockerized dchp+tftp server,\
for serving PXE-bootable images"

#RUN apk add --no-cache --virtual sl_plus_deps "syslinux>=6.03-r0" && \
#    cp -r /usr/share/syslinux /tftpboot && \
#    find /tftpboot -type f -exec chmod 0444 {} + && \
#    apk del sl_plus_deps

COPY ["mapfile", "netboot.xyz.kpxe", "/tftpboot/"]
#COPY ["pxelinux.cfg", "/tftpboot/pxelinux.cfg/"]

# http://forum.alpinelinux.org/apk/main/x86_64/tftp-hpa
RUN apk add --no-cache tftp-hpa dhcp && \
    touch /var/lib/dhcp/dhcpd.leases && \
    adduser -D tftp

# Do not track further change to /tftpboot or the dhcp conf directory
VOLUME /tftpboot /etc/dhcp/conf.d

EXPOSE 69/udp 67/udp 67/tcp

# copy in our starter-file (starts dhcp & tftpd
COPY ["start", "auto-dhcp", "/usr/sbin/"]
# use it as an entrypoint (DEFAULT exec mode)
ENTRYPOINT ["/usr/sbin/start"]
# and supply it's default args
CMD ["-L", "--verbose", "-u", "tftp", "--secure", "/tftpboot"]

