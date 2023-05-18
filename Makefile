NAME=qcode
RELEASE=0
DPKG_NAME=qcode-tcl-$(VERSION)
INSTALL_DIR=qcode-tcl
TEMP_PATH=/tmp/$(INSTALL_DIR)
MAINTAINER=hackers@qcode.co.uk
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
	tar --strip-components=1 --exclude Makefile --exclude description-pak --exclude doc --exclude docs.tcl --exclude package.tcl \
	-xzvf v$(VERSION).tar.gz -C $(TEMP_PATH)
	./package.tcl $(TEMP_PATH)/tcl package ${NAME} ${VERSION}
	./pkg_mkIndex package
	# checkinstall
	fakeroot checkinstall -D --deldoc --backup=no --install=no --pkgname=$(DPKG_NAME) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) \
	-A all -y --maintainer $(MAINTAINER) --pkglicense="BSD" --reset-uids=yes --requires "tcl,tcllib,html2text,curl,tclcurl" \
	--replaces none --conflicts none make install

test: package
	cd $(TEMP_PATH) && tclsh test/all.tcl

install:  
	mkdir -p /usr/lib/tcltk/$(NAME)$(VERSION)
	cp package/*.tcl /usr/lib/tcltk/$(NAME)$(VERSION)/
	cp LICENSE /usr/lib/tcltk/$(NAME)$(VERSION)/

upload: check-version
	scp $(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb "$(REMOTEUSER)@$(REMOTEHOST):$(REMOTEDIR)/debs"	
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) includedeb buster $(REMOTEDIR)/debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb
	ssh $(REMOTEUSER)@$(REMOTEHOST) rm -f $(REMOTEDIR)/debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb

clean: check-version
	rm -rf package
	rm -rf $(TEMP_PATH)
	rm $(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb
	rm -f v$(VERSION).tar.gz

check-version:
ifndef VERSION
    $(error VERSION is undefined. Usage make VERSION=x.x.x)
endif
