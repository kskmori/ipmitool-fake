SHAREDIR=$(DESTDIR)/usr/share/ipmitool-fake
SPECFILE=ipmitool-fake.spec

DISTDIR=ipmitool-fake
TARFILE=ipmitool-fake.tar

INSTALL=/usr/bin/install

all:
	@echo nothing to do.

conf:
	@[ -e ipmitool-fake.conf ] || cp ipmitool-fake.conf.in ipmitool-fake.conf
	vi ipmitool-fake.conf


ipmitool-fake.conf:
	@echo "Copy and do customize ipmitool-fake.conf file before make rpm."
	@echo "ex. $ cp ipmitool-fake.conf.in ipmitool-fake.conf && vi ipmitool-fake.conf"
	@false

dist: ipmitool-fake.conf
	mkdir -p $(DISTDIR)
	git commit -m "DO-NOT-PUSH" -a
	git checkout-index -a -f --prefix=$(DISTDIR)/
	git reset --mixed HEAD^
	cp -p ipmitool-fake.conf $(DISTDIR)/
	tar cfvj $(TARFILE).bz2 $(DISTDIR)
	mv $(TARFILE).bz2 $$(rpm --eval %{_sourcedir})
	rm -rf $(DISTDIR)/

install:
	$(INSTALL) -m 755 -d $(SHAREDIR)
	$(INSTALL) -m 755 ipmitool-fake.sh $(SHAREDIR)
	$(INSTALL) -m 644 ipmitool-fake.conf $(SHAREDIR)
	$(INSTALL) -m 755 install-fake.sh $(SHAREDIR)

rpm: dist
	rpmbuild -bb $(SPECFILE)

clean:
	rm -f *~
	rm -f ipmitool-fake.conf
	rm -f $(TARFILE).bz2
	rm -rf $(DISTDIR)/
