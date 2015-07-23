#
# Makefile for subiquity
#
PYTHONSRC=subiquity
PYTHONPATH=$(shell pwd):$(shell pwd)/probert:$PYTHONPATH
VENVPATH=$(shell pwd)/venv
VENVACTIVATE=$(VENVPATH)/bin/activate
TOPDIR=$(shell pwd)
STREAM=daily
RELEASE=wily
ARCH=amd64
BOOTLOADER=grub2
OFFLINE=-o
INSTALLIMG=ubuntu-server-${STREAM}-${RELEASE}-${ARCH}-installer.img
INSTALLER_RESOURCES += $(shell find installer/resources -type f)
.PHONY: run clean

all: dryrun

dryrun:
	$(MAKE) ui-view DRYRUN="--dry-run"

ui-view:
	(PYTHONPATH=$(PYTHONPATH) bin/$(PYTHONSRC) $(DRYRUN))

ui-view-serial:
	(TERM=att4424 PYTHONPATH=$(PYTHONPATH) bin/$(PYTHONSRC) $(DRYRUN) --serial)

lint:
	echo "Running flake8 lint tests..."
	flake8 bin/$(PYTHONSRC) --ignore=F403
	flake8 --exclude $(PYTHONSRC)/tests/ $(PYTHONSRC) --ignore=F403

unit:
	echo "Running unit tests..."
	python3 -m "nose" -v --nologcapture --with-coverage $(PYTHONSRC)/tests/

installer/$(INSTALLIMG): installer/geninstaller installer/runinstaller $(INSTALLER_RESOURCES)
	(cd installer && ./geninstaller -v $(OFFLINE) -r $(RELEASE) -a $(ARCH) -s $(STREAM) -b $(BOOTLOADER)) 
	echo $(INSTALLER_RESOURCES)

installer: installer/$(INSTALLIMG)

run: installer
	(cd installer && INSTALLER=$(INSTALLIMG) ./runinstaller)

clean:
	rm -f installer/target.img
	rm -f installer/installer.img
	rm -f installer/geninstaller.log
	find installer -type f -name *-installer.img | xargs -i rm {}
