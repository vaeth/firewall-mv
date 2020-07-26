# firewall-mv

(C) Martin Väth <martin at mvath.de>
This project is under the BSD license 2.0 (“3-clause BSD license”).
SPDX-License-Identifier: BSD-3-Clause

A collection of POSIX shell scripts to initialize iptables and
net-related sysctl variables of Linux.

These POSIX scripts set some typical __iptables__ commands for a dialup PC,
optionally including a simple portknocking solution and router functionality.
The usage is somewhat similar to __SuSEfirewall2__, but the approach has
some essential differences. In particular, packets are usually not `DROP`-ed
but `REJECT`-ed until a rate-limit is reached. It is not necessary to restart
the firewall after a connection is established.
Currently, IPv6 is practically not supported (except for closing everything).

The setting of the kernel variables is done with a separate script sysctl.net

By default, firewall makes use of the functions from `firewall-scripted.sh`
which allow a "scripted" use of `iptables-restore` and `ip6tables-restore`.
This means that all __iptables__ rules are created in one command.
This has not only the advantage that it is much faster, but, moreover,
it avoids race conditions when creating the rules,see
- http://inai.de/documents/Perfect_Ruleset.pdf

See the instruction at the end how to use `firewall-scripted.sh`.

To install this project easily, run `make` (and `make install` as root).
For manual installation, copy the scripts from `sbin/` into your `PATH`.
`etc/firewall.config` can be copied into `/etc` or `/usr/lib/firewall` or
`/lib/firewall` (if it is readable in a former directory, it is used;
thus, the latter can be used to provide distribution-wide defaults).
You should modify `firewall.config` to your needs (for the default, copy
`etc/firewall.d` to the `/etc` directory and follow `etc/firewall.d/README`).
For __zsh completion__ support copy the content of zsh into your `$fpath`.

You also need `push.sh` from https://github.com/vaeth/push (v2.0 or newer)
in your `PATH`.

Before you run firewall, please edit `firewall.config` to your needs:
You have to create it in `/etc/firewall.config` to override the sample default
from `/usr/lib/firewall` or `/lib/firewall`.
The example `firewall.config` sets the default based on the existence of some
magic files in `/etc`. It assumes that the original `eth*` interfaces have
been renamed to `net*` (e.g. by __eudev__ or __udev__ rules).

The firewall script reads your `firewall.config` and then
(by default) runs `sysctl.net` and initializes __iptables__ according
to the content of `firewall.config`.

`sysctl.net` initializes some net-related Linux __sysctl__ variables.

To get help, run `firewall -h` or `sysctl.net -h`, respectively.

If you use __systemd__, you can copy the content of `systemd` into your
systemd system folder and (after `systemctl daemon-reload`) enable the
scripts with
```
	systemctl enable firewall.service
```

For __openrc__ (the Gentoo init system) there are some scripts provided in
the openrc folder. Copy these scripts and their configs to `/etc/init.d`
or `/etc/conf.d`, respectively and edit `/etc/conf.d`.
To activate the firewall with openrc, call e.g.
(the runlevels might depend on your configuration):
```
	rc-config add fireclose boot
	rc-config add firewall default
```
Instead of adding `fireclose` to your boot runlevel, you might also want to
add to your relevant `/etc/conf.d/net*` file(s):
```
rc_need=fireclose
```

To load the required kernel modules with systemd or openrc, copy e.g. the
content of `modules-load.d/` to `/etc/modules-load.d/` or
`/usr/lib/modules-load.d/` and edit it for your needs.
__Systemd__ and __openrc-0.21.7__ (or newer) automatically support
these directories.
For older versions of openrc, you can use the `conf.d/modules` file to get
at least some rudimentary support of these directories.

For Gentoo, there is an ebuild in the mv overlay (available by layman)
(but you might still have to configure the firewall.config, see above).

## Instructions for firewall-scripted.sh:

### Step 1.

Evaluate the output of firewall-scripted.sh in a POSIX compliant shell, e.g.
```
if SOME_VARIABLE=`firewall-scripted.sh 2>/dev/null`
then	eval "$SOME_VARIABLE"
else	echo "firewall-scripted.sh not installed" >&2
fi
```
__Remark__: An obsoleted method was to use instead
```
. firewall-scripted.sh
```
The latter works for older versions of firwall-mv or if one installs manually,
but unless an appropriate PATH before sourcing is set, it fails when
firewall-scripted.sh is replaced by a wrapper script which happens with the
provided Makefile. Moreover, if firwell-scripted.sh is not available it stops
the script.

All functions and variables used internally by firewall-scripted.sh have the
form Fwmv[A-Z]* or fwmv_*, respectively, so do not use these.
All these variables are cleaned up by firewall-scripted.sh when possible.

### Step 2.

Call `FwmvTable 4` or `FwmvTable 6` instead of `iptables` or `ip6tables`,
respectively. You can pass most options of `iptables` or `ip6tables` in exactly
the same form; if you use the option `-t`, it must be the first one.

### Step 3.

When you are done, you can execute the "stored" commands in one step using
`FwmvSet 4` or `FwmvSet 6`, respectively.
If you pass additionally the parameter `Echo` (possibly combined with `Exec`),
the command is printed instead (and only executed if you also passed `Exec`).
In this case, `firewall-scripted.sh` requires the `push.sh` script (and uses
the functions/variables used by `push.sh` in addition to those from Step 1.)

### Step 4.

After Step 3 all variables are reset so that you can start over with Step 2.

### Disclaimer

Not all options for `FwmvTable` in `firewall-scripted.sh` are tested;
essentially only those used by the `firewall` script are tested.
In particular, `ip6tables` is not tested at all with `firewall-scripted.sh`.
