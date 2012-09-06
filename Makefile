NAME=qcode
VERSION=1.7
PACKAGEDIR=qcode
TESTDIR=test
MAINTAINER=hackers@qcode.co.uk
RELEASE=$(shell cat RELEASE)
REMOTEUSER=debian.qcode.co.uk
REMOTEHOST=debian.qcode.co.uk
REMOTEDIR=debian.qcode.co.uk

.PHONY: all test

all: package upload clean incr-release
package:
	checkinstall -D --deldoc --backup=no --install=no --pkgname=$(NAME)-$(VERSION) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) -A all -y --maintainer $(MAINTAINER) --pkglicense="BSD" --reset-uids=yes --requires "tcl8.5,tcllib,qcode-doc,html2text,curl,tclcurl" --replaces none --conflicts none make install

test:
	make install
	tclsh ./test_all.tcl -testdir $(TESTDIR) 

install:
	./pkg_mkIndex $(PACKAGEDIR)
	mkdir -p /usr/lib/tcltk/$(PACKAGEDIR)$(VERSION)
	cp $(PACKAGEDIR)/*.tcl /usr/lib/tcltk/$(PACKAGEDIR)$(VERSION)/
	cp LICENSE /usr/lib/tcltk/$(PACKAGEDIR)$(VERSION)/

upload:
	scp $(NAME)-$(VERSION)_$(VERSION)-$(RELEASE)_all.deb "$(REMOTEUSER)@$(REMOTEHOST):$(REMOTEDIR)/debs"	
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) includedeb squeeze $(REMOTEDIR)/debs/$(NAME)-$(VERSION)_$(VERSION)-$(RELEASE)_all.deb

clean:
	rm $(NAME)-$(VERSION)_$(VERSION)-$(RELEASE)_all.deb

incr-release:
	./incr-release-number.tcl

uninstall:
	rm -r /usr/lib/tcltk/$(PACKAGEDIR)$(VERSION)
