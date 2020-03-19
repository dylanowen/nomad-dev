SHELL:=/bin/bash

.DEFAULT_GOAL := docker

username = $(shell whoami)

alias = nomad-dev
ports = -p 2222:22 \
	-p 8080:8080 \
	--publish=60000-60010:60000-60010/udp
volumes = -v $(HOME)/code:/home/$(username)/code \
	-v $(HOME)/.gradle:/home/$(username)/.gradle \
	-v $(PWD)/ssh/.ssh:/home/$(username)/.ssh \
	-v $(PWD)/ssh/keys:/etc/ssh/keys \
	-v /var/run/docker.sock:/var/run/docker.sock
dockerDefaults = $(ports) \
					  $(volumes) \
					  --cap-add=SYS_PTRACE \
					  --init \
					  $(alias)

docker:
	docker build --build-arg NewUserName=$(username) -t $(alias) .

ssh/keys:
	mkdir ssh/keys
	ssh-keygen -f ssh/keys/ssh_host_rsa_key -N '' -t rsa
	ssh-keygen -f ssh/keys/ssh_host_dsa_key -N '' -t dsa
	ssh-keygen -f ssh/keys/ssh_host_ed25519_key -N '' -t ed25519
	ssh-keygen -f ssh/keys/ssh_host_ecdsa_key -N '' -t ecdsa

debug: docker ssh/keys
	docker run -it $(dockerDefaults) /bin/bash

foreground: docker ssh/keys
	docker run -it $(dockerDefaults)

background: docker ssh/keys
	docker run -d $(dockerDefaults)

develop: docker ssh/keys
	while true; do make foreground; done

clean:
	docker rmi $(alias)
# mosh -ssh='ssh -o "StrictHostKeyChecking no" -p 2222' localhost
