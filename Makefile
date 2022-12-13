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

EXAMPLE_NEDS = cisco-asa-cli-6.6
NEDS_PATH = $(EXAMPLE_NEDS:%=packages/%)

.PHONY: example-neds
example-neds: $(NEDS_PATH)
	make -C $(NEDS_PATH:%=%/src)

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