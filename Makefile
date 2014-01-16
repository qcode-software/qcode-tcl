NAME=qcode
VERSION=3.0.4
RELEASE=0
MAINTAINER=hackers@qcode.co.uk
REMOTEUSER=debian.qcode.co.uk
REMOTEHOST=debian.qcode.co.uk
REMOTEDIR=debian.qcode.co.uk

.PHONY: all test

all: test package upload git-tag clean
package: 
	fakeroot checkinstall -D --deldoc --backup=no --install=no --pkgname=$(NAME)-$(VERSION) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) -A all -y --maintainer $(MAINTAINER) --pkglicense="BSD" --reset-uids=yes --requires "tcl8.5,tcllib,qcode-doc,html2text,curl,tclcurl" --replaces none --conflicts none make install

tcl-package :
	rm -rf package
	mkdir package
	./package.tcl package ${NAME} ${VERSION}
	./pkg_mkIndex package

test: tcl-package 
	tclsh ./test_all.tcl -testdir test
	rm -rf package

install: tcl-package
	mkdir -p /usr/lib/tcltk/$(NAME)$(VERSION)
	cp package/*.tcl /usr/lib/tcltk/$(NAME)$(VERSION)/
	cp LICENSE /usr/lib/tcltk/$(NAME)$(VERSION)/
	rm -rf package

upload:
	scp $(NAME)-$(VERSION)_$(VERSION)-$(RELEASE)_all.deb "$(REMOTEUSER)@$(REMOTEHOST):$(REMOTEDIR)/debs"	
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) includedeb squeeze $(REMOTEDIR)/debs/$(NAME)-$(VERSION)_$(VERSION)-$(RELEASE)_all.deb
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) includedeb wheezy $(REMOTEDIR)/debs/$(NAME)-$(VERSION)_$(VERSION)-$(RELEASE)_all.deb

clean:
	rm $(NAME)-$(VERSION)_$(VERSION)-$(RELEASE)_all.deb

git-tag:
	git tag -a "v$(VERSION)" -m "create tag v$(VERSION)"
	git push origin --tags
