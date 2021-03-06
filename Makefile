cmd=

all: updateManifest build run

updateManifest:
	python -c "import bagit; bag = bagit.Bag('$(bagtainer)'); bag.save(manifests=True); print('Updated manifest. Is Bag valid?', bag.validate());"
.PHONY: updateManifest

build:
	docker build -t bagtainers/$(bagtainer) $(bagtainer)/data/container/.
.PHONY: build

uploader-build:
	docker build -t o2r-uploader .
.PHONY: uploader-run

uploader-run:
	docker run --rm o2r-uploader
.PHONY: uploader-run

run:
	docker run --rm -it -v $(shell pwd)/$(bagtainer):/bag:ro -v /tmp/o2r_run:/o2r_run:rw bagtainers/$(bagtainer) $(cmd)
.PHONY: run
