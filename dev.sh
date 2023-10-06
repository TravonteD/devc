#!/bin/sh

SHELL=${DEVC_SHELL:-bash}
DEVCONTAINER_JSON=""
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
        touch ".devcontainer.json"
        ;;
      directory)
        mkdir -p ".devcontainer" && touch ".devcontainer/devcontainer.json"
        ;;
    esac
  else
    exit
  fi
fi

if [ -n "$1" ]
then
  COMMAND=$1
  shift
else
  COMMAND=$(gum choose "up" "exec" "edit" "shell" "kill" "restart")
fi

CONTAINER_FILE="$CACHE_DIR/.$(basename "$PWD")).json" 

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

run_with_existing() {
  if [ -n "${CONTAINER_ID}" ]
  then
    $*
  else
    printf "%s" "container found. bring up the container using `devc up`"
  fi
}

case ${COMMAND} in
  up)
    devcontainer up --workspace-folder . > "$CONTAINER_FILE"
    ;;
  exec)
    if [ -n "$*" ]
    then
      CMD="$*"
    else
      CMD=$(gum input --prompt "Enter the command to execute: ")
    fi
    run_with_existing docker container exec -w "${CONTAINER_FOLDER}" -it "${CONTAINER_ID}" ${CMD}
    ;;
  edit)
    if [ -f ".devcontainer.json" ]; then
      $EDITOR .devcontainer.json
    else
      $EDITOR .devcontainer/devcontainer.json
    fi
    ;;
  shell)
    run_with_existing docker container exec -w "${CONTAINER_FOLDER}" -it "${CONTAINER_ID}" $SHELL
    ;;
  stop)
    run_with_existing docker container stop "${CONTAINER_ID}"
    ;;
  kill)
    IMAGE_ID=$(docker image ls | grep "vsc-$(basename $(pwd))" | cut -d' ' -f1)
    VOLUME_ID=$(docker volume ls | grep "vsc-$(basename $(pwd))" | cut -d' ' -f1)
    if [ -n "${CONTAINER_ID}" ]
    then
      gum spin --title "Removing devcontainer" -- docker container rm --force "${CONTAINER_ID}"
      gum spin --title "Removing image" -- docker image rm --force "${IMAGE_ID}"
      gum spin --title "Removing volume" -- docker volume rm --force "${VOLUME_ID}"
    fi
    ;;
  restart)
    run_with_existing docker container restart "${CONTAINER_ID}"
    ;;
  rebuild)
    $0 kill; $0 up
    ;;
  *)
    printf "no command specified\n"
    ;;
esac
