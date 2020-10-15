NAME=qcode
RELEASE=0
DPKG_NAME=qcode-tcl-$(VERSION)
INSTALL_DIR=qcode-tcl
TEMP_PATH=/tmp/$(INSTALL_DIR)
MAINTAINER=hackers@qcode.co.uk
REMOTEUSER_LEGACY=debian.qcode.co.uk
REMOTEHOST_LEGACY=debian.qcode.co.uk
REMOTEDIR_LEGACY=debian.qcode.co.uk
REMOTEUSER=deb
REMOTEHOST=deb.qcode.co.uk
REMOTEDIR=deb.qcode.co.uk

.PHONY: all test

all: check-version package test upload clean
package: check-version
	# Copy files to pristine temporary directory
	rm -rf $(TEMP_PATH)	
	mkdir $(TEMP_PATH)
	rm -rf package
	mkdir package
	curl --fail -K ~/.curlrc_github -L -o v$(VERSION).tar.gz https://api.github.com/repos/qcode-software/qcode-tcl/tarball/v$(VERSION)
	tar --strip-components=1 --exclude Makefile --exclude description-pak --exclude doc --exclude docs.tcl --exclude package.tcl -xzvf v$(VERSION).tar.gz -C $(TEMP_PATH)
	./package.tcl tcl package ${NAME} ${VERSION}
	./pkg_mkIndex package
	# checkinstall
	fakeroot checkinstall -D --deldoc --backup=no --install=no --pkgname=$(DPKG_NAME) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) -A all -y --maintainer $(MAINTAINER) --pkglicense="BSD" --reset-uids=yes --requires "tcl,tcllib,html2text,curl,tclcurl" --replaces none --conflicts none make install

tcl-package: check-version
	rm -rf package
	mkdir package
	./package.tcl $(TEMP_PATH)/tcl package ${NAME} ${VERSION}
	./pkg_mkIndex package

test: tcl-package 
	tclsh $(TEMP_PATH)/test/all.tcl


install: tcl-package 
	mkdir -p /usr/lib/tcltk/$(NAME)$(VERSION)
	cp package/*.tcl /usr/lib/tcltk/$(NAME)$(VERSION)/
	cp LICENSE /usr/lib/tcltk/$(NAME)$(VERSION)/

upload: check-version
	scp $(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb "$(REMOTEUSER_LEGACY)@$(REMOTEHOST_LEGACY):$(REMOTEDIR_LEGACY)/debs"
	ssh $(REMOTEUSER_LEGACY)@$(REMOTEHOST_LEGACY) reprepro -b $(REMOTEDIR_LEGACY) includedeb jessie $(REMOTEDIR_LEGACY)/debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb
	scp $(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb "$(REMOTEUSER)@$(REMOTEHOST):$(REMOTEDIR)/debs"	
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) includedeb stretch $(REMOTEDIR)/debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) copy buster stretch $(DPKG_NAME)

clean: check-version
	rm -rf package
	rm -rf $(TEMP_PATH)
	rm $(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb
	rm -f v$(VERSION).tar.gz

check-version:
ifndef VERSION
    $(error VERSION is undefined. Usage make VERSION=x.x.x)
endif
