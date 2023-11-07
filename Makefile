# Makefile pentru Tema 2, v0.1
# Puteți înlocui fără probleme Makefile-ul curent din VM

# numele artefactului Yocto care va genera imaginea
# Modificați-l dacă folosiți *-minimal sau orice altă imagine !!
YOCTO_ARTIFACT = core-image-base
YOCTO_MACHINE = qemuarm
# unde sa se genereze arhiva cu binarele
BIN_TMP_DIR = build/tmp/bin_archive

# adăugați fișiere de ignorat (e.g., pe cele din laborator)
ZIP_IGNORE_FILES=kas.yml meta-lab* meta-tutorial*

SHELL=/bin/bash

build:
	kas build tema2.yml

_YOCTO_IMAGE_DIR = build/tmp/deploy/images/$(YOCTO_MACHINE)
bin_archive:
	@if ! command -v zip &>/dev/null; then echo "Please install zip!"; exit 1; fi
	@mkdir -p "$(BIN_TMP_DIR)/"
	cp -f "$(_YOCTO_IMAGE_DIR)/zImage" "$(BIN_TMP_DIR)/kernel"
	cp -f "$(_YOCTO_IMAGE_DIR)/$(YOCTO_ARTIFACT)-$(YOCTO_MACHINE).ext4" \
		"$(BIN_TMP_DIR)/rootfs.img"
	cp -f launch_bin.sh "$(BIN_TMP_DIR)/"
	tar czvf bin_archive.tar.gz -C "$(BIN_TMP_DIR)/" .

bin_checksum:
	sha256sum bin_archive.tar.gz > checksum.txt
	cat checksum.txt

source_archive: bin_checksum
	@if ! command -v zip &>/dev/null; then echo "Please install zip!"; exit 1; fi
	@rm -f "source_archive.zip"
	zip -r -y source_archive.zip . -x '*.zip' -x '*.tar.gz' -x 'build/*' -x 'layers/*' \
		$(patsubst %,-x '%',$(ZIP_IGNORE_FILES))

clean:
	rm -rf bin_archive.tar.gz source_archive.zip "$(BIN_TMP_DIR)"

.PHONY: build bin_archive bin_checksum source_archive clean

