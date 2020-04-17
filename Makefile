PROGRAM_NAME=whoami
VERSION=2.0

DATA_DIR=/usr/share
DOCS_DIR=$(DATA_DIR)/doc
PROGRAM_DIR=/usr/local/bin

install:

	
	install -Dm755 Tproxy.sh $(PROGRAM_DIR)/$(PROGRAM_NAME)
	mkdir -p $(DATA_DIR)/$(PROGRAM_NAME)/data
	mkdir -p $(DATA_DIR)/$(PROGRAM_NAME)/backups
	install -Dm644 data/* $(DATA_DIR)/$(PROGRAM_NAME)/data

uninstall:

	rm -Rf $(PROGRAM_DIR)/$(PROGRAM_NAME)
	rm -Rf $(DATA_DIR)/$(PROGRAM_NAME)
	rm -Rf $(DOCS_DIR)/$(PROGRAM_NAME)