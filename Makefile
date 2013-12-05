NAME=qcode
VERSION=2.6.0
$(shell ./set-version-number.tcl ${NAME} ${VERSION})
RELEASE=$(shell cat RELEASE)
MAINTAINER=hackers@qcode.co.uk
REMOTEUSER=debian.qcode.co.uk
REMOTEHOST=debian.qcode.co.uk
REMOTEDIR=debian.qcode.co.uk

.PHONY: all test

all: test package upload clean incr-release
package: 
	checkinstall -D --deldoc --backup=no --install=no --pkgname=$(NAME)-$(VERSION) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) -A all -y --maintainer $(MAINTAINER) --pkglicense="BSD" --reset-uids=yes --requires "tcl8.5,tcllib,qcode-doc,html2text,curl,tclcurl" --replaces none --conflicts none make install

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

incr-release:
	./incr-release-number.tcl

uninstall:
	rm -r /usr/lib/tcltk/$(NAME)$(VERSION)
