PREFIX ?= ~/.local
INSTALLATION_DIR ?= $(PREFIX)/bin
MAN_DIR ?= $(PREFIX)/man/man1

PROGRAM_NAME ?= devc

install: $(INSTALLATION_DIR)/$(PROGRAM_NAME) $(MAN_DIR)/$(PROGRAM_NAME).1

uninstall:
	rm -rf $(INSTALLATION_DIR)/$(PROGRAM_NAME) $(MAN_DIR)/$(PROGRAM_NAME).1
 
$(INSTALLATION_DIR)/$(PROGRAM_NAME): dev.sh
	mkdir -p $(INSTALLATION_DIR)
	cp $^ $@
	chmod +x $@

$(MAN_DIR)/$(PROGRAM_NAME).1: $(PROGRAM_NAME).1
	mkdir -p $(MAN_DIR)
	cp $(PROGRAM_NAME).1 $@

$(PROGRAM_NAME).1: man.md
	pandoc --standalone $^ -o $@
