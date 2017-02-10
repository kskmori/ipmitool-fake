SHAREDIR=$(DESTDIR)/usr/share/ipmitool-fake
SPECFILE=ipmitool-fake.spec
DISTFILE=ipmitool-fake.tar.gz

INSTALL=/usr/bin/install

all:
	@echo nothing to do.

dist: 
	(cd .. && tar cfvz $(DISTFILE) ipmitool-fake)  ## TBI
	mv ../$(DISTFILE) $$(rpm --eval %{_sourcedir}) ## TBI

install:
	$(INSTALL) -m 755 -d $(SHAREDIR)
	$(INSTALL) -m 755 ipmitool-fake.sh $(SHAREDIR)
	$(INSTALL) -m 644 ipmitool-fake.conf.sample $(SHAREDIR)
	$(INSTALL) -m 755 install-fake.sh $(SHAREDIR)

rpm: dist
	rpmbuild -bb $(SPECFILE)

clean:
	rm -f *~
