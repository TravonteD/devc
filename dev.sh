#!/bin/sh

SHELL=${DEVC_SHELL:-bash}

# Check for devcontainer configuration
DEVCONTAINER_JSON=""
if [ -f ".devcontainer.json" ]
then
  DEVCONTAINER_JSON=".devcontainer.json "
elif [ -f ".devcontainer/devcontainer.json" ]
then
  DEVCONTAINER_JSON=".devcontainer/devcontainer.json"
fi

if [ -z "$DEVCONTAINER_JSON" ]
then
  if gum confirm "No devcontainer configuration found would you like to create one?"
  then
    CHOICE=$(gum choose "standalone (.devcontainer.json)" "directory (.devcontainer/devcontainer.json)" | cut -d' ' -f1)
    case $CHOICE in
      standalone)
        DEVCONTAINER_JSON=".devcontainer.json"
        touch ".devcontainer.json"
        ;;
      directory)
        DEVCONTAINER_JSON=".devcontainer/devcontainer.json"
        mkdir -p ".devcontainer" && touch ".devcontainer/devcontainer.json"
        ;;
    esac
    EDITOR="$DEVCONTAINER_JSON"
  else
    exit
  fi
fi

# Check for existing devcontiainer
if [ -n "$XDG_CACHE_DIR" ]
then
  CACHE_DIR="$XDG_CACHE_DIR/devc"
else
  CACHE_DIR="$HOME/.cache/devc"
fi
if ! [ -d "$CACHE_DIR" ]
then
  mkdir -p "$CACHE_DIR"
fi
CONTAINER_FILE="$CACHE_DIR/.$(basename "$PWD").json" 
# Handle deprecation of the old .container.json in the working directory
OLD_CONTAINER_FILE=".container.json" 
if [ -f "$OLD_CONTAINER_FILE" ]
then
  mv "$OLD_CONTAINER_FILE" "$CONTAINER_FILE"
fi
if [ -f "$CONTAINER_FILE" ]
then
  CONTAINER_ID=$(jq -r '.containerId' < "$CONTAINER_FILE")
  CONTAINER_FOLDER=$(jq -r '.remoteWorkspaceFolder' < "$CONTAINER_FILE")
fi

devc_up() {
    devcontainer up --workspace-folder . > "$CONTAINER_FILE"
}

run_with_existing() {
  if ! [ -n "${CONTAINER_ID}" ]
  then
    printf 'container found. bringing up the container using "devc up"'
    devc_up
  fi
  $*
}

if [ -n "$1" ]
then
  COMMAND=$1
  shift
else
  COMMAND=$(gum choose "up" "exec" "background" "logs" "edit" "shell" "kill" "restart")
fi

devc_exec() {
    if [ -n "$*" ]
    then
      CMD="$*"
    else
      CMD=$(gum input --prompt "Enter the command to execute: ")
    fi
    run_with_existing docker container exec -w "${CONTAINER_FOLDER}" -it "${CONTAINER_ID}" "${CMD}"
}

devc_background() {
    if [ -n "$*" ]
    then
      CMD="$*"
    else
      CMD=$(gum input --prompt "Enter the command to execute: ")
    fi
    run_with_existing docker container exec -w "${CONTAINER_FOLDER}" -dt "${CONTAINER_ID}" "${CMD}"
}

devc_edit() {
    if [ -f ".devcontainer.json" ]; then
      $EDITOR .devcontainer.json
    else
      $EDITOR .devcontainer/devcontainer.json
    fi
}

devc_kill() {
    IMAGE_ID=$(docker image ls | grep "vsc-$(basename "$PWD")" | cut -d' ' -f1)
    VOLUME_ID=$(docker volume ls | grep "vsc-$(basename "$PWD")" | cut -d' ' -f1)
    if [ -n "${CONTAINER_ID}" ]
    then
      gum spin --title "Removing devcontainer" -- docker container rm --force "${CONTAINER_ID}"
      gum spin --title "Removing image" -- docker image rm --force "${IMAGE_ID}"
      gum spin --title "Removing volume" -- docker volume rm --force "${VOLUME_ID}"
      rm "$CONTAINER_FILE"
    fi
}

devc_shell() {
    run_with_existing docker container exec -w "${CONTAINER_FOLDER}" -it "${CONTAINER_ID}" "$SHELL"
}


case ${COMMAND} in
  up)
    devc_up
    ;;
  exec)
    devc_exec "$*"
    ;;
  background)
    devc_background "$*"
    ;;
  edit)
    devc_edit
    ;;
  shell)
    devc_shell
    ;;
  start)
    devc_up && devc_shell
    ;;
  stop)
    run_with_existing docker container stop "${CONTAINER_ID}"
    ;;
  kill)
    devc_kill
    ;;
  restart)
    run_with_existing docker container restart "${CONTAINER_ID}"
    ;;
  rebuild)
    devc_kill; devc_up
    ;;
  *)
    printf "no command specified\n"
    ;;
esac
