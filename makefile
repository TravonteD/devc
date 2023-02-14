PREFIX ?= ~/.local
INSTALLATION_DIR ?= $(PREFIX)/bin
MAN_DIR ?= $(PREFIX)/man/man1

PROGRAM_NAME ?= devc

install: $(INSTALLATION_DIR)/$(PROGRAM_NAME) $(MAN_DIR)/$(PROGRAM_NAME).1
 
$(INSTALLATION_DIR)/$(PROGRAM_NAME): dev.sh
	cp $^ $@

$(MAN_DIR)/$(PROGRAM_NAME).1: $(MAN_DIR) $(PROGRAM_NAME).1
	cp $^ $@

$(PROGRAM_NAME).1: man.md
	pandoc --standalone $^ -o $@

$(MAN_DIR):
	mkdir -p $@

$(INSTALLATION_DIR):
	mkdir -p $@
