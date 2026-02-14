# Makefile

# Define the target
.PHONY: help sync_hosts quick1 quick2 quick3 groups

# Path to the hosts.yml file
HOSTS_FILE := ~/.config/zellij/layouts/hosts.yml

# Zellij layout file
LAYOUT_FILE := ~/.config/zellij/layouts/tmplayout.kdl

# Hostname suffix (override with `make ... HOST_SUFFIX=...`)
HOST_SUFFIX := .convoso.com

help:
	@grep -E '[a-zA-Z0-9\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#' | sed -E 's/Makefile.//' | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

#sync_hosts: @ Grab latest hosts.yml from sink2
sync_hosts:
	@scp sink2-lv.convoso.com:~/Projects/vosocli/hosts.yml ~/.config/zellij/layouts/hosts.yml

#groups: @ Display list of host groups
groups:
	@yq eval 'keys | .[]' $(HOSTS_FILE)

# Create temp Zellij layout (internal)
_quick:
	@if [ -z "$(filter-out quick1 quick2 quick3 _quick,$(MAKECMDGOALS))" ]; then \
		echo "Missing host/group argument. Usage: make quick1|quick2|quick3 <group-name> OR make quick1|quick2|quick3 <host1> <host2> ..."; \
		exit 1; \
	fi
	@echo "Generating Zellij layout from $(HOSTS_FILE)..."
	@echo "layout {" > $(LAYOUT_FILE)
	@echo "    pane_template name=\"ssh\" borderless=false {" >> $(LAYOUT_FILE)
	@echo "        command \"ssh\"" >> $(LAYOUT_FILE)
	@echo "    }" >> $(LAYOUT_FILE)
	@echo "" >> $(LAYOUT_FILE)
	@echo "    pane split_direction=\"horizontal\" {" >> $(LAYOUT_FILE)

	# Resolve a single argument as an inventory group, otherwise treat args as host list
	@set -e; \
	args="$(filter-out quick1 quick2 quick3 _quick,$(MAKECMDGOALS))"; \
	args="$${args//,/ }"; \
	if [ "$$(printf '%s\n' $$args | wc -w | tr -d ' ')" -eq 1 ] && \
	   yq eval "has(\"$$args\")" $(HOSTS_FILE) | grep -q true; then \
		hosts="$$(yq eval ".\"$$args\".hosts | keys | .[]" $(HOSTS_FILE))"; \
	else \
		hosts="$$args"; \
	fi; \
	rows="$(ROWS)"; \
	if [ -z "$$rows" ] || [ "$$rows" -le 0 ]; then rows=1; fi; \
	count="$$(printf '%s\n' $$hosts | wc -l | tr -d ' ')"; \
	per_row="$$(($$count / $$rows))"; \
	extra="$$(($$count % $$rows))"; \
	start=1; \
	for i in $$(seq 1 $$rows); do \
		row_count="$$per_row"; \
		if [ "$$i" -le "$$extra" ]; then row_count="$$((row_count + 1))"; fi; \
		end="$$(($$start + $$row_count - 1))"; \
		echo "        pane split_direction=\"vertical\" {" >> $(LAYOUT_FILE); \
		if [ "$$row_count" -gt 0 ]; then \
			printf '%s\n' $$hosts | awk -v s="$$start" -v e="$$end" 'NR>=s && NR<=e' | \
			while read -r host; do \
				fqdn="$$host$(HOST_SUFFIX)"; \
				echo "            ssh {" >> $(LAYOUT_FILE); \
				echo "                args \"$$fqdn\"" >> $(LAYOUT_FILE); \
				echo "            }" >> $(LAYOUT_FILE); \
			done; \
		fi; \
		echo "        }" >> $(LAYOUT_FILE); \
		start="$$(($$end + 1))"; \
	done; \
	echo "    }" >> $(LAYOUT_FILE); \
	echo "    pane size=2 borderless=true {" >> $(LAYOUT_FILE); \
	echo "        plugin location=\"zellij:status-bar\"" >> $(LAYOUT_FILE); \
	echo "    }" >> $(LAYOUT_FILE); \
	echo "}" >> $(LAYOUT_FILE)

	@zellij --layout $(notdir $(LAYOUT_FILE))

#quick1: @ Open hosts in a single row layout
quick1: ROWS=1
quick1: _quick

#quick2: @ Open hosts in a two rows layout
quick2: ROWS=2
quick2: _quick

#quick3: @ Open hosts in a three rows layout
quick3: ROWS=3
quick3: _quick

# Treat additional input as arguments, so do not see them as targets
%:
	@:
