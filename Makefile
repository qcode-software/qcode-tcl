NAME=qcode
VERSION=2.6.4
$(shell ./set-version-number.tcl ${NAME} ${VERSION})
RELEASE=0
MAINTAINER=hackers@qcode.co.uk
REMOTEUSER=debian.qcode.co.uk
REMOTEHOST=debian.qcode.co.uk
REMOTEDIR=debian.qcode.co.uk

.PHONY: all test

all: test package upload git-tag clean
package: 
	fakeroot checkinstall -D --deldoc --backup=no --install=no --pkgname=$(NAME)-$(VERSION) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) -A all -y --maintainer $(MAINTAINER) --pkglicense="BSD" --reset-uids=yes --requires "tcl8.5,tcllib,qcode-doc,html2text,curl,tclcurl" --replaces none --conflicts none make install

test:   
	./pkg_mkIndex tcl
	tclsh ./test_all.tcl -testdir test

install: 
	./pkg_mkIndex tcl
	mkdir -p /usr/lib/tcltk/$(NAME)$(VERSION)
	cp tcl/*.tcl /usr/lib/tcltk/$(NAME)$(VERSION)/
	cp LICENSE /usr/lib/tcltk/$(NAME)$(VERSION)/

upload:
	scp $(NAME)-$(VERSION)_$(VERSION)-$(RELEASE)_all.deb "$(REMOTEUSER)@$(REMOTEHOST):$(REMOTEDIR)/debs"	
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) includedeb squeeze $(REMOTEDIR)/debs/$(NAME)-$(VERSION)_$(VERSION)-$(RELEASE)_all.deb
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) includedeb wheezy $(REMOTEDIR)/debs/$(NAME)-$(VERSION)_$(VERSION)-$(RELEASE)_all.deb

clean:
	rm $(NAME)-$(VERSION)_$(VERSION)-$(RELEASE)_all.deb

git-tag:
	git tag -a "v$(VERSION)" -m "create tag v$(VERSION)"
	git push origin --tags