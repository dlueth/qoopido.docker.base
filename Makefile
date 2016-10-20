tag?=develop

build:
	docker build --no-cache=true -t qoopido/base:${tag} .