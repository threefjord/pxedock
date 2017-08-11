tftp-hpa (tftpd) in a container
===============================

Project URL: [https://github.com/Lunsford94/pxedock/](https://github.com/Lunsford94/pxedock/)

Registry: [https://registry.hub.docker.com/u/slicedbread/pxedock/](https://registry.hub.docker.com/u/slicedbread/pxedock/)


Overview
--------

This source is used to build an image for
[tftp-hpa](https://git.kernel.org/cgit/network/tftp/tftp-hpa.git/).
The image contains:

* H. Peter Anvin's [tftp server](https://git.kernel.org/cgit/network/tftp/tftp-hpa.git/)
* default, minimal configuration that you can easily override
* the isc-dhcp-server
* [map file](src/mapfile)
  to rewrite certain request paths

The image contains a base tftpd and dhcp server
to PXE-boot your hosts. The default dhcp configuration
will listen for broadcasts on a best guess of the
current subnet, but will not offer any addresses. It
will also check the hostlist for changes every minute
(configurable) and restart the dhcp server if needed. 
The default tftpd server will contain only the 
[`netboot.xyz.kpxe`](netboot.xyz) file. 

How-to
------

### Fetch the pre-built image

The runtime image is not yet published, but wil be as `slicedbread/pxedock`.

    docker pull slicedbread/pxedock

### Configure and run

At minimum, to provide the [`netboot.xyz.kpxe`](netboot.xyz) to hosts
you need to provide entries in the form of:

    host <hostname> {
      hardware ethernet <mac-addr>;
      fixed-address <intended ip>;
    }

In the hostlist file to have the dhcp server offer to them. The
following are examples of possible running configurations:

Run a the container (without providing a host list, will not DHCPOffer, but useful to test connection?):

    docker run -d --net=host \
	-p 67:67 -p 67:67/udp -p 69:69 \
	slicedbread/pxedock

Run the container, providing a list of hosts in a hostlist file in the conf.d directory:

    docker run -d --net=host \
	-v $(pwd)/conf.d:/etc/dhcp/conf.d:ro \
	-p 67:67 -p 67:67/udp -p 69:69 \
	slicedbread/pxedock

Run the container, providing both the hostlist, and your own tftp root (make sure to provide your own pxe-booting target file, will default to netboot.xyz.kpxe)

    docker run -d --net=host \
	-e PXE_target=<your intended base pxe-bootable> \
	-v $(pwd)/conf.d:/etc/dhcp/conf.d:ro \
	-v $(pwd)/tftpfake:/tftpboot:ro \
	-p 67:67 -p 67:67/udp -p 69:69 \
	slicedbread/pxedock

Run the container, specifying your own DNS server, if necessary:

    docker run -d --net=host \
	-e DNS=137.78.160.9 \
	-p 67:67 -p 67:67/udp -p 69:69 \
	slicedbread/pxedock


License
-------

See [`LICENSE`](LICENSE) in this repo.

