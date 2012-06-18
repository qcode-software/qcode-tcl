NAME=qcode
VERSION=1.5
PACKAGEDIR=qcode
MAINTAINER=hackers@qcode.co.uk
RELEASE=$(shell cat RELEASE)
REMOTEUSER=debian.qcode.co.uk
REMOTEHOST=debian.qcode.co.uk
REMOTEDIR=debian.qcode.co.uk

.PHONY: all

all: package upload clean incr-release
package:
	checkinstall -D --deldoc --backup=no --install=no --pkgname=$(NAME) --pkgversion=$(VERSION) --pkgrelease=$(RELEASE) -A all -y --maintainer $(MAINTAINER) --pkglicense="BSD" --reset-uids=yes --requires "tcl8.5,tcllib,qcode-doc,html2text,curl,tclcurl" make install

install:
	./pkg_mkIndex $(PACKAGEDIR)
	mkdir -p /usr/lib/tcltk/$(PACKAGEDIR)$(VERSION)
	cp $(PACKAGEDIR)/*.tcl /usr/lib/tcltk/$(PACKAGEDIR)$(VERSION)/
	cp LICENSE /usr/lib/tcltk/$(PACKAGEDIR)$(VERSION)/

upload:
	scp $(NAME)_$(VERSION)-$(RELEASE)_all.deb "$(REMOTEUSER)@$(REMOTEHOST):$(REMOTEDIR)/debs"	
	ssh $(REMOTEUSER)@$(REMOTEHOST) reprepro -b $(REMOTEDIR) includedeb squeeze $(REMOTEDIR)/debs/$(NAME)_$(VERSION)-$(RELEASE)_all.deb

clean:
	rm $(NAME)_$(VERSION)-$(RELEASE)_all.deb

incr-release:
	./incr-release-number.tcl

uninstall:
	rm -r /usr/lib/tcltk/$(PACKAGEDIR)$(VERSION)
