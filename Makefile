SHAREDIR=$(DESTDIR)/usr/share/ipmitool-fake
SPECFILE=ipmitool-fake.spec

DISTDIR=ipmitool-fake
TARFILE=ipmitool-fake.tar
RPMFILE=ipmitool-fake-0.1-1.noarch.rpm

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

ansible-install:
	cp -p  $$(rpm --eval %{_rpmdir})/noarch/$(RPMFILE) ./ansible/roles/ipmitool-fake-install/files/
	(cd ansible; ansible-playbook -i hosts 10-ipmitool-fake-install.yml)

ansible-uninstall:
	(cd ansible; ansible-playbook -i hosts 99-ipmitool-fake-uninstall.yml)

preview:
	grip README.md

distclean: clean
	rm -f ipmitool-fake.conf
	rm -f ./ansible/hosts

clean:
	rm -f *~
	rm -f $(TARFILE).bz2
	rm -rf $(DISTDIR)/
	rm -f ./ansible/*.retry
	rm -f ./ansible/roles/ipmitool-fake-install/files/*
