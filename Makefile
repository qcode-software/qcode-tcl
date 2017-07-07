NAME=qcode
RELEASE=0
DPKG_NAME=qcode-tcl-$(VERSION)
MAINTAINER=hackers@qcode.co.uk
REMOTEUSER=debian.qcode.co.uk
REMOTEHOST=debian.qcode.co.uk
REMOTEDIR=debian.qcode.co.uk

.PHONY: all test

all: check-version package test upload clean
package: check-version
	# Copy files to pristine temporary directory
	rm -rf package
	mkdir package
	curl --fail -K ~/.curlrc_github -L -o v$(VERSION).tar.gz https://api.github.com/repos/qcode-software/qcode-tcl/tarball/v$(VERSION)
	tar --strip-components=1 --exclude Makefile --exclude description-pak --exclude doc --exclude docs.tcl --exclude package.tcl -xzvf v$(VERSION).tar.gz -C package
	./package.tcl package/tcl package/tcl ${NAME} ${VERSION}
	./pkg_mkIndex package
	# checkinstall
	fakeroot checkinstall -D --deldoc --backup=no --install=no --pkgname=$(DPKG_NAME) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) -A all -y --maintainer $(MAINTAINER) --pkglicense="BSD" --reset-uids=yes --requires "tcl8.5,tcllib,html2text,curl,tclcurl" --replaces none --conflicts none make local-install

local-package : check-version
	rm -rf package
	mkdir package
	./package.tcl tcl package/tcl ${NAME} ${VERSION}
	cp LICENSE package
	./pkg_mkIndex package

local-test: local-package 
	tclsh ./test_all.tcl -testdir test
	rm -rf package

test:  
	tclsh ./test_all.tcl -testdir package/test
	rm -rf package

install: local-package local-install
	rm -rf package

local-install:
	mkdir -p /usr/lib/tcltk/$(NAME)$(VERSION)
	cp package/tcl/*.tcl /usr/lib/tcltk/$(NAME)$(VERSION)/
	cp package/LICENSE /usr/lib/tcltk/$(NAME)$(VERSION)/

upload: check-version
	scp $(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb "$(REMOTEUSER)@$(REMOTEHOST):$(REMOTEDIR)/debs"	
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) includedeb wheezy $(REMOTEDIR)/debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) includedeb jessie $(REMOTEDIR)/debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb

clean: check-version
	rm $(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb
	rm -f v$(VERSION).tar.gz

check-version:
ifndef VERSION
    $(error VERSION is undefined. Usage make VERSION=x.x.x)
endif
