NAME=qcode
RELEASE=0
DPKG_NAME=qcode-tcl
INSTALL_DIR=qcode-tcl
TEMP_PATH=/tmp/$(INSTALL_DIR)
TEMP_PATH_DEBIAN=/tmp/${DPKG_NAME}_$(VERSION)-$(RELEASE)
MAINTAINER=hackers@qcode.co.uk
REMOTEUSER=deb

REMOTEHOST=ssh.debian.qcode.co.uk
REMOTEDIR=debian.qcode.co.uk

.PHONY: all test

all: check-version package test upload clean
package: check-version
	# Copy files to pristine temporary directory
	rm -rf $(TEMP_PATH)	
	mkdir $(TEMP_PATH)
	rm -rf ${TEMP_PATH_DEBIAN}/usr/lib/tcltk/tcl8/site-tcl
	mkdir -p ${TEMP_PATH_DEBIAN}/usr/lib/tcltk/tcl8/site-tcl
	rm -rf ${TEMP_PATH_DEBIAN}/DEBIAN
	mkdir -p ${TEMP_PATH_DEBIAN}/DEBIAN
	rm -rf package
	mkdir package
	curl --fail -K ~/.curlrc_github -L -o v$(VERSION).tar.gz https://api.github.com/repos/qcode-software/qcode-tcl/tarball/v$(VERSION)
	tar --strip-components=1 --exclude Makefile --exclude description-pak --exclude doc --exclude docs.tcl --exclude package.tcl \
	-xzvf v$(VERSION).tar.gz -C $(TEMP_PATH)
	./package.tcl $(TEMP_PATH)/tcl ${TEMP_PATH_DEBIAN}/usr/lib/tcltk/tcl8/site-tcl ${NAME} ${VERSION}
	./control.tcl ${TEMP_PATH_DEBIAN}/DEBIAN ${DPKG_NAME} ${VERSION} ${RELEASE} ${MAINTAINER}
	# build package
	dpkg-deb --build ${TEMP_PATH_DEBIAN} $(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb

test: package
	cd $(TEMP_PATH) && tclsh test/all.tcl

install:
	dpkg -i /tmp/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb

upload: check-version
	scp $(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb "$(REMOTEUSER)@$(REMOTEHOST):$(REMOTEDIR)/debs"	
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) includedeb buster $(REMOTEDIR)/debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) copy bookworm buster $(DPKG_NAME)
	ssh $(REMOTEUSER)@$(REMOTEHOST) rm -f $(REMOTEDIR)/debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb

clean: check-version
	rm -rf package
	rm -rf $(TEMP_PATH)
	rm -rf ${TEMP_PATH_DEBIAN}
	rm $(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb
	rm -f v$(VERSION).tar.gz

check-version:
ifndef VERSION
    $(error VERSION is undefined. Usage make VERSION=x.x.x)
endif
