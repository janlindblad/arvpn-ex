###################################################
# ARVPN Example Top Makefile
###################################################

.PHONY: all start stop cli
all: example-neds dc-ned arvpn-svc netsim

start: stop
	@if [ ! -d netsim ]; then echo "You need to   make all   first."; false; fi
	ncs-netsim start
	ncs

stop:
	-ncs-netsim stop 2>/dev/null 1>&2
	-ncs --stop 2>/dev/null 1>&2

cli:
	-ncs_cli -Cu admin

###################################################
# NETSIM Devices
###################################################

netsim:
	ncs-netsim create-network packages/cisco-asa-cli-6.6/ 1 asa
	ncs-netsim ncs-xml-init > ncs-cdb/netsim-init.xml

###################################################
# ARVPN-SVC
###################################################

.PHONY: arvpn-svc
arvpn-svc: packages/arvpn-svc/load-dir/arvpn-svc.fxs

packages/arvpn-svc/load-dir/arvpn-svc.fxs:
	make -C packages/arvpn-svc/src

###################################################
# DC-NED
###################################################

.PHONY: dc-ned
dc-ned:

###################################################
# EXAMPLE-NEDS
###################################################

EXAMPLE_NEDS = cisco-asa-cli-6.6 cisco-xr-um-7.8.1 nokia-sros-22.7
NEDS_PATH = $(EXAMPLE_NEDS:%=packages/%)

.PHONY: example-neds

example-neds: $(NEDS_PATH)
	for ned in $(NEDS_PATH:%=%/src); do make -C $$ned; done

# Build NETCONF NEDs from YANG source
packages/%: yangs/%
	ncs-make-package --netconf-ned $< $(notdir $@) --dest $@ --no-java --no-python

# Copy CLI NEDs from NSO examples
packages/%: $(NCS_DIR)/packages/neds/%
	cp -r $< $@

###################################################
# CLEAN
###################################################

clean:
	make -C packages/arvpn-svc/src clean
	rm -rf netsim
	rm -rf $(NEDS_PATH)

###################################################
###################################################