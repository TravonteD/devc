#!/bin/sh

if ! command -v gum > /dev/null
then
  printf "%s" 'gum is not installed. install it via homebrew with `brew install gum`'
fi

if [ -n "$1" ]
then
  command=$1
  shift
else
  command=$(gum choose "up" "exec" "edit" "shell" "kill" "restart")
fi

container_id=$(jq -r '.containerId' < .container.json)
container_folder=$(jq -r '.remoteWorkspaceFolder' < .container.json)

case ${command} in
  up)
    devcontainer up --workspace-folder . > .container.json
    ;;
  exec)
    if [ -n "$*" ]
    then
      cmd="$*"
    else
      cmd=$(gum input --prompt "Enter the command to execute: ")
    fi
    docker container exec -w "${container_folder}" -it "${container_id}" ${cmd}
    ;;
  edit)
    $EDITOR .devcontainer/devcontainer.json
    ;;
  shell)
    if [ -n "${container_id}" ]
    then
      docker container exec -w "${container_folder}" -it "${container_id}" bash
    fi
    ;;
  stop)
    if [ -n "${container_id}" ]
    then
      docker container stop "${container_id}"
    fi
  kill)
    image_id=$(docker image ls | grep "vsc-$(basename $(pwd))" | cut -d' ' -f1)
    volume_id=$(docker volume ls | grep "vsc-$(basename $(pwd))" | cut -d' ' -f1)
    if [ -n "${container_id}" ]
    then
      gum spin --title "Removing devcontainer" -- docker container rm --force "${container_id}"
      gum spin --title "Removing image" -- docker image rm --force "${image_id}"
      gum spin --title "Removing volume" -- docker volume rm --force "${volume_id}"
    fi
    ;;
  restart)
    $0 kill; $0 up
    ;;
  *)
    printf "no command specified\n"
    ;;
esac
