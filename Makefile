NAME=qcode-tcl
RELEASE=0
DPKG_NAME=$(NAME)-$(VERSION)
TEMP_PATH=/tmp/$(DPKG_NAME)
MAINTAINER=hackers@qcode.co.uk
REMOTEUSER=debian.qcode.co.uk
REMOTEHOST=debian.qcode.co.uk
REMOTEDIR=debian.qcode.co.uk

.PHONY: all test

all: check-version test package upload clean
package: check-version
	# Copy files to pristine temporary directory
	rm -rf $(TEMP_PATH)
	mkdir $(TEMP_PATH)
	curl --fail -K ~/.curlrc_github -L -o v$(VERSION).tar.gz https://api.github.com/repos/qcode-software/$(NAME)/tarball/v$(VERSION)
	tar --strip-components=1 --exclude Makefile --exclude description-pak --exclude doc --exclude docs.tcl --exclude package.tcl --exclude test --exclude test_all.tcl -xzvf v$(VERSION).tar.gz -C $(TEMP_PATH)
	# checkinstall
	fakeroot checkinstall -D --deldoc --backup=no --install=no --pkgname=$(DPKG_NAME) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) -A all -y --maintainer $(MAINTAINER) --pkglicense="BSD" --reset-uids=yes --requires "tcl8.5,tcllib,qcode-doc,html2text,curl,tclcurl" --replaces none --conflicts none make install-github

tcl-package-github : check-version
	rm -rf package
	mkdir package
	./package.tcl $(TEMP_PATH) package ${NAME} ${VERSION}
	./pkg_mkIndex package

tcl-package : check-version
	rm -rf package
	mkdir package
	./package.tcl tcl package ${NAME} ${VERSION}
	./pkg_mkIndex package

test: tcl-package 
	tclsh ./test_all.tcl -testdir test
	rm -rf package

install: tcl-package
	mkdir -p /usr/lib/tcltk/$(NAME)$(VERSION)
	cp package/*.tcl /usr/lib/tcltk/$(NAME)$(VERSION)/
	cp LICENSE /usr/lib/tcltk/$(NAME)$(VERSION)/
	rm -rf package

install-github: tcl-package-github
	mkdir -p /usr/lib/tcltk/$(NAME)$(VERSION)
	cp package/*.tcl /usr/lib/tcltk/$(NAME)$(VERSION)/
	cp LICENSE /usr/lib/tcltk/$(NAME)$(VERSION)/
	rm -rf package
upload:
	scp $(NAME)-$(VERSION)_$(VERSION)-$(RELEASE)_all.deb "$(REMOTEUSER)@$(REMOTEHOST):$(REMOTEDIR)/debs"	
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) includedeb squeeze $(REMOTEDIR)/debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) includedeb wheezy $(REMOTEDIR)/debs/$(DPKG_NAME)_$(VERSION)-$(RELEASE)_all.deb

clean:
	rm $(NAME)-$(VERSION)_$(VERSION)-$(RELEASE)_all.deb

check-version:
ifndef VERSION
    $(error VERSION is undefined. Usage make VERSION=x.x.x)
endif
