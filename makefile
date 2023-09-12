PREFIX ?= ~/.local
INSTALLATION_DIR ?= $(PREFIX)/bin
MAN_DIR ?= $(PREFIX)/man/man1

PROGRAM_NAME ?= devc

EXECUTABLE = command -v $1 2> /dev/null

GUM := $(call EXECUTABLE, gum)
JQ := $(call EXECUTABLE, jq)
DEVCONTAINER := $(call EXECUTABLE, DEVCONTAINER)

ifndef GUM
	$(error "gum is not installed. install it via homebrew with `brew install gum`")
endif

ifndef JQ
	$(error "jq is not installed. install it via homebrew with `brew install jq`")
endif

ifndef DEVCONTAINER
	$(error "devcontainer is not installed. install it via npm with `npm install -g @devcontainers/cli`")
endif

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
