pxedock - PXE-booting from a docker container
===============================

Project URL: [https://github.com/Lunsford94/pxedock/](https://github.com/Lunsford94/pxedock/)

Registry: [https://registry.hub.docker.com/u/slicedbread/pxedock/](https://registry.hub.docker.com/u/slicedbread/pxedock/)


Overview
--------

This source can be used to build an image for a pxe-boot server.
The image contains:

* H. Peter Anvin's [tftp server](https://git.kernel.org/cgit/network/tftp/tftp-hpa.git/)
* the [ISC DHCP server](https://www.isc.org/downloads/dhcp/)
* default, minimal configuration using [`netboot.xyz`](http://netboot.xyz)
that you can easily override
* lightweight DHCP managing [script](auto-dhcp)

The image contains a tftpd and dhcp server to
PXE-boot your hosts. The default dhcp configuration
will listen for broadcasts on a best guess of the
current subnet, but will not offer any addresses. It
will also check the hostlist for changes every minute
(configurable) and restart the dhcp server if needed. 
The default tftpd server will contain only the 
[`netboot.xyz.kpxe`](http://netboot.xyz) file. 

This was originally based on jumanhihouse's [docker-tftp-hpa](https://github.com/jumanjihouse/docker-tftp-hpa), from which I basically learned how to docker. 

Running
------

### Fetch the pre-built image

The image is published as `slicedbread/pxedock`.

    docker pull slicedbread/pxedock

### Configure and run

At minimum, to provide the [`netboot.xyz.kpxe`](http://netboot.xyz) to hosts
you need to have dhcp host entries in the form of:

    host <hostname> {
      hardware ethernet <mac-addr>;
      fixed-address <intended ip>;
    }

in the hostlist file, (specified with the env variable 
'host_file', default 'hostlist', and mounted from host onto 
container's /etc/dhcp/conf.d) to have the dhcp server 
recognize and offer addresses to them. The following 
are examples of possible running configurations (all 
assuming files in current directory, with host list in 
$(pwd)/conf.d/$host_file):

Run a the container (without providing a host list, will 
not DHCPOffer, but useful to test connection?):

    docker run -d --net=host \
	-p 67:67 -p 67:67/udp -p 69:69/udp \
	slicedbread/pxedock

Run the container, providing a list of hosts in a hostlist 
file in the conf.d directory:

    docker run -d --net=host \
	-v $(pwd)/conf.d:/etc/dhcp/conf.d:ro \
	-p 67:67 -p 67:67/udp -p 69:69/udp \
	slicedbread/pxedock

Run the container, providing a list of hosts in a hostlist 
file named `list_of_hosts` in the conf.d directory:

    docker run -d --net=host \
	-e host_file=list_of_hosts \
	-v $(pwd)/conf.d:/etc/dhcp/conf.d:ro \
	-p 67:67 -p 67:67/udp -p 69:69/udp \
	slicedbread/pxedock

Run the container, providing both the hostlist, and your 
own tftp root (make sure to provide your own pxe-boot target 
file, will default to netboot.xyz.kpxe)

    docker run -d --net=host \
	-e PXE_target=<your intended base pxe-bootable> \
	-v $(pwd)/conf.d:/etc/dhcp/conf.d:ro \
	-v $(pwd)/tftpfake:/tftpboot:ro \
	-p 67:67 -p 67:67/udp -p 69:69/udp \
	slicedbread/pxedock

Run the container, specifying the ip address of the interface 
it should listen on (will generate dhcpd.conf properly to listen to it):

    docker run -d --net=host \
	-e IP=172.16.0.5 \
	-p 67:67 -p 67:67/udp -p 69:69/udp \
	slicedbread/pxedock

Run the container, specifying your own DNS server, if 
necessary (this will be provided to the clients) 
(*default is 8.8.8.8*):

    docker run -d --net=host \
	-e DNS=192.168.0.2 \
	-p 67:67 -p 67:67/udp -p 69:69/udp \
	slicedbread/pxedock

Run the container, checking for updates to the hostlist 
at a much slower frequency:

    docker run -d --net=host \
	-e DHCP_update_time=600 \
	-v $(pwd)/conf.d:/etc/dhcp/conf.d:ro \
	-p 67:67 -p 67:67/udp -p 69:69/udp \
	slicedbread/pxedock

License
-------

See [`LICENSE`](LICENSE) in this repo.

