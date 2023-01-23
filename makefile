INSTALLATION_DIR ?= ~/.local/bin

PROGRAM_NAME ?= devc

install: $(INSTALLATION_DIR)/$(PROGRAM_NAME)

$(INSTALLATION_DIR)/$(PROGRAM_NAME): dev.sh
	cp $^ $@
