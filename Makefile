PREFIX=
EPREFIX=
BINDIR=$(PREFIX)/sbin
LIBDIR=$(PREFIX)/lib/firewall
DATADIR=$(LIBDIR)
ETCDIR=$(PREFIX)/etc
OPENRCDIR=$(ETCDIR)
MODULESLOADDIR=$(PREFIX)/usr/lib/modules-load.d
SYSTEMDDIR=$(EPREFIX)/lib/systemd
SYSTEMUNITDIR=$(SYSTEMDDIR)/system
ZSH_FPATH=$(PREFIX)/share/zsh/site-functions

.PHONY: FORCE all install uninstall clean distclean maintainer-clean

all: firewall-scripted.sh

firewall-scripted.sh:
	echo '#!$(EPREFIX)/bin/cat $(DATADIR)/firewall-scripted.sh' >firewall-scripted.sh

install: firewall-scripted.sh
	install -d '$(DESTDIR)$(BINDIR)'
	install -d '$(DESTDIR)/$(DATADIR)'
	install -d '$(DESTDIR)/$(LIBDIR)'
	install -d '$(DESTDIR)/$(ETCDIR)'
	install -d '$(DESTDIR)/$(ETCDIR)/firewall.d'
	install -d '$(DESTDIR)/$(ZSH_FPATH)'
	install -d '$(DESTDIR)/$(MODULESLOADDIR)'
	install -m 755 sbin/firewall '$(DESTDIR)$(BINDIR)/firewall'
	install -m 755 sbin/sysctl.net '$(DESTDIR)$(BINDIR)/sysctl.net'
	install -m 755 firewall-scripted.sh '$(DESTDIR)$(BINDIR)/firewall-scripted.sh'
	install -m 644 sbin/firewall-scripted.sh '$(DESTDIR)$(DATADIR)/firewall-scripted.sh'
	install -m 644 etc/firewall.config '$(DESTDIR)$(LIBDIR)/firewall.config'
	install -m 644 etc/firewall.d/README '$(DESTDIR)$(ETCDIR)/firewall.d/README'
	[ -z '$(OPENRCDIR)' ] || install -d '$(DESTDIR)$(OPENRCDIR)/init.d'
	[ -z '$(OPENRCDIR)' ] || install -d '$(DESTDIR)$(OPENRCDIR)/conf.d'
	[ -z '$(OPENRCDIR)' ] || install -m 755 openrc/init.d/firewall '$(DESTDIR)$(OPENRCDIR)/init.d/firewall'
	[ -z '$(OPENRCDIR)' ] || install -m 755 openrc/init.d/fireclose '$(DESTDIR)$(OPENRCDIR)/init.d/fireclose'
	[ -z '$(OPENRCDIR)' ] || install -m 644 openrc/conf.d/firewall '$(DESTDIR)$(OPENRCDIR)/conf.d/firewall'
	[ -z '$(OPENRCDIR)' ] || install -m 644 openrc/conf.d/fireclose '$(DESTDIR)$(OPENRCDIR)/conf.d/fireclose'
	[ -z '$(SYSTEMDDIR)' ] || install -d '$(DESTDIR)$(SYSTEMUNITDIR)'
	[ -z '$(SYSTEMDDIR)' ] || install -m 644 systemd/firewall.service '$(DESTDIR)$(SYSTEMUNITDIR)/firewall.service'
	[ -z '$(SYSTEMDDIR)' ] || install -m 644 systemd/firewall-close.service '$(DESTDIR)$(SYSTEMUNITDIR)/firewall-close.service'
	[ -z '$(MODULESLOADDIR)' ] || install -d '$(DESTDIR)$(MODULESLOADDIR)'
	[ -z '$(MODULESLOADDIR)' ] || install -m 644 modules-load.d/firewall.conf '$(DESTDIR)$(MODULESLOADDIR)/firewall.conf'
	[ -z '$(ZSH_FPATH)' ] || install -d '$(DESTDIR)$(ZSH_FPATH)'
	[ -z '$(ZSH_FPATH)' ] || install -m 644 zsh/_firewall '$(DESTDIR)$(ZSH_FPATH)/_firewall'

uninstall: FORCE
	rm -f '$(DESTDIR)/$(BINDIR)/firewall'
	rm -f '$(DESTDIR)/$(BINDIR)/sysctl.net'
	rm -f '$(DESTDIR)/$(BINDIR)/firewall-scripted.sh'
	rm -f '$(DESTDIR)/$(DATADIR)/firewall-scripted.sh'
	-rmdir '$(DESTDIR)/$(DATADIR)'
	rm -f '$(DESTDIR)/$(LIBDIR)/firewall-scripted.sh'
	-rmdir '$(DESTDIR)/$(LIBDIR)'
	rm -f '$(DESTDIR)/$(ETCDIR)/firewall.d/README'
	-rmdir '$(DESTDIR)/$(ETCDIR)/firewall.d'
	-rmdir '$(DESTDIR)/$(ETCDIR)'
	[ -z '$(OPENRCDIR)' ] || rm -f '$(DESTDIR)$(OPENRCDIR)/init.d/firewall'
	[ -z '$(OPENRCDIR)' ] || rm -f '$(DESTDIR)$(OPENRCDIR)/init.d/fireclose'
	[ -z '$(OPENRCDIR)' ] || rm -f '$(DESTDIR)$(OPENRCDIR)/conf.d/firewall'
	[ -z '$(OPENRCDIR)' ] || rm -f '$(DESTDIR)$(OPENRCDIR)/conf.d/fireclose'
	-[ -z '$(OPENRCDIR)' ] || rmdir '$(DESTDIR)$(OPENRCDIR)/conf.d'
	-[ -z '$(OPENRCDIR)' ] || rmdir '$(DESTDIR)$(OPENRCDIR)/init.d'
	-[ -z '$(OPENRCDIR)' ] || rmdir '$(DESTDIR)$(OPENRCDIR)'
	[ -z '$(SYSTEMDDIR)' ] || rm -f '$(DESTDIR)$(SYSTEMUNITDIR)/firewall.service'
	[ -z '$(SYSTEMDDIR)' ] || rm -f '$(DESTDIR)$(SYSTEMUNITDIR)/firewall-close.service'
	-[ -z '$(SYSTEMDDIR)' ] || rmdir '$(DESTDIR)$(SYSTEMUNITDIR)'
	-[ -z '$(SYSTEMDDIR)' ] || rmdir '$(DESTDIR)$(SYSTEMDDIR)'
	[ -z '$(MODULESLOADDIR)' ] || rm -f '$(DESTDIR)/$(MODULESLOADDIR)/firewall.conf'
	-[ -z '$(MODULESLOADDIR)' ] || rmdir '$(DESTDIR)/$(MODULESLOADDIR)'
	[ -z '$(ZSH_FPATH)' ] || rm -f '$(DESTDIR)/$(ZSH_FPATH)/_firewall'
	-[ -z '$(ZSH_FPATH)' ] || rmdir '$(DESTDIR)/$(ZSH_FPATH)'

clean: FORCE
	rm -f ./firewall-scripted.sh

distclean: clean FORCE
	rm -f ./firewall-mv-*.asc ./firewall-mv-*.tar.* ./firewall-mv-*.tar ./firewall-mv-*.zip

maintainer-clean: distclean FORCE

FORCE:
