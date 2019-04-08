SHELL:=/bin/bash

.DEFAULT_GOAL := docker

alias = nomad-dev
udpPorts = 60000-60010:60000-60010/udp
username = $(shell whoami)

docker:
	docker build --build-arg NewUserName=$(username) -t $(alias) .

debug: docker
	docker run -it $(alias) /bin/bash

foreground: docker
	docker run -it -p 2222:22 --publish=$(udpPorts) \
		-v ~/code:/home/$(username)/code \
		-v ~/.gradle:/home/$(username)/.gradle \
		$(alias)

background: docker
	docker run -d -p 2222:22 --publish=$(udpPorts) $(alias)

# mosh -ssh='ssh -o "StrictHostKeyChecking no" -p 2222' localhost