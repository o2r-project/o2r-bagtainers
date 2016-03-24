cmd=

all: build run

build:
	docker build -t bagtainers/$(bagtainer) $(bagtainer)/data/container/.
.PHONY: build

run:
	docker run --rm -it -v $(shell pwd)/$(bagtainer):/bag:ro -v /tmp/o2r_run:/o2r_run:rw bagtainers/$(bagtainer) $(cmd)
.PHONY: run
