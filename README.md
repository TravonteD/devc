# devc: A convenient wrapper around the [devcontainer-cli](https://github.com/devcontainers/cli)

## Features

- A tui interface based on [gum](https://github.com/charmbracelet/gum)
- Automatically handles removal of containers, images, and volumes created by the cli
- Adds the following new functionality
  + `shell`: Starts a shell in the devcontainer at the workspace directory
  + `edit`: A quick shortcut for opening your `devcontainer.json` with your favorite editor (Be sure to export `EDITOR` for this functionality)
  + `kill`: Does a full shutdown and removal of the current devcontainer 
  + `restart`: Does a quick reboot of the devcontainer
  + `rebuild`: Kills the devcontainer and starts a new one from scratch

## Installation
- Install the following dependencies:
  - `jq`
  - `gum`
  - `devcontainer`

- Update the `makefile` with your desired installation directory and command name
- Run `make install`

## Usage

```bash
devc [command]
```

Available commands:
  - up : Starts the dev-container
  - exec : Runs a single command in the container
  - background : Same as `exec` in the background
  - edit : Opens the `.devcontainer/devcontainer.json` in your `$EDITOR`
  - shell : Starts an interactive shell in the container at the workspace folder
  - stop : Stops the container without removing it
  - kill : Removes the container, image, and volume for the container
  - restart : Reboots the container
  - rebuild : Equivalent to **kill** + **up**
