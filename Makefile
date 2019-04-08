SHELL:=/bin/bash

.DEFAULT_GOAL := docker

username = $(shell whoami)

alias = nomad-dev
volumes = -v $(HOME)/code:/home/$(username)/code \
	-v $(HOME)/.gradle:/home/$(username)/.gradle
udpPorts = 60000-60010:60000-60010/udp

docker:
	docker build --build-arg NewUserName=$(username) -t $(alias) .

debug: docker
	docker run -it $(volumes) $(alias) /bin/bash

foreground: docker
	docker run -it -p 2222:22 --publish=$(udpPorts) \
		$(volumes) \
		$(alias)

background: docker
	docker run -d -p 2222:22 --publish=$(udpPorts)  \
		$(volumes) \
		$(alias)

# mosh -ssh='ssh -o "StrictHostKeyChecking no" -p 2222' localhost
