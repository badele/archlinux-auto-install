MAKEFLAGS += --no-print-directory
.DEFAULT_GOAL := help
ISOCHECKSUM=${shell curl http://mir.archlinux.fr/iso/${ARCHVERSION}/sha256sums.txt | grep "archlinux-x86_64.iso" | grep -Eo '^[0-9a-z]{64}'}
TMPDIR=/var/tmp
ARCHVERSION ?= 2022.10.01
NAME = base

.POSIX:
.PHONY: *

help: ## This help
	@find . -name Makefile -o -name "*.mk" | xargs -n1 grep -hE '^[a-z0-9\-]+:.* ##' | sed 's/\: .*##/:/g' | sort | column  -ts':'

doc-generate: ## Generate main Readme commands list
	@make > /tmp/doc-generate.txt
	@bash -c 'export COMMANDS="$$(cat /tmp/doc-generate.txt)" ; envsubst < README.tpl > README.md'

toolkit: ## Homelab toolkit(for building a homelab stack)
	@command -v nix-shell > /dev/null && nix-shell --pure || docker run \
		--name homelab-admin \
		--rm \
		--interactive \
		--tty \
		--network host \
		--volume "/var/run/docker.sock:/var/run/docker.sock" \
		--volume $$(pwd):$$(pwd) \
		--volume ${HOME}/.ssh:/root/.ssh \
		--volume nixos-cache:/root/.cache \
		--volume nixos-nix:/nix \
		--workdir $$(pwd) \
		nixos/nix nix-shell

archlinux-versions: ## List all archlinux versions
	@curl -sL http://mir.archlinux.fr/iso/ | grep -Eo '20[0-9]{2}\.[0-9]{2}\.[0-9]{2}' | sort -u

.iso/archlinux-${ARCHVERSION}-x86_64.iso:
	mkdir -p ${ARCHVERSION} && wget -O .iso/archlinux-${ARCHVERSION}-x86_64.iso http://mir.archlinux.fr/iso/${ARCHVERSION}/archlinux-x86_64.iso

vagrant-build: .iso/archlinux-${ARCHVERSION}-x86_64.iso ## [ARCHVERSION] <NAME> Build vagrant box 
	@cp config/${NAME}/* install/
	@echo "Building ${NAME} archlinux ${ARCHVERSION} version"
	@rm -rf box
	@TMPDIR=${TMPDIR} packer build \
		-var arch_version="${ARCHVERSION}" \
		-var arch_iso_checksum="${ISOCHECKSUM}" \
		-var outputname=${NAME} packer.pkr.hcl
	@NAME="${NAME}" vagrant box add --force archlinux-${NAME} file://./box/archlinux-${NAME}-${ARCHVERSION}-virtualbox.box

vagrant-up: ## Test vagrant box [ARCHVERSION] <NAME>
	@NAME="${NAME}" vagrant up

vagrant-ssh: ## Connect to vagrant box [ARCHVERSION] <NAME>
	@NAME="${NAME}" vagrant ssh

vagrant-destroy: ## Destroy vagrant box [ARCHVERSION] <NAME>
	@NAME="${NAME}" vagrant destroy

vagrant-push: ## Push vagrant box [ARCHVERSION] <NAME>
	@NAME="${NAME}" vagrant cloud publish \
	--force \
	--release \
	--no-private \
	--short-description "${NAME}+LUKS archlinux ${ARCHVERSION}" \
	badele/archlinux-${NAME} ${ARCHVERSION} virtualbox box/archlinux-${NAME}-${ARCHVERSION}-virtualbox.box
