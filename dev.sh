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

if [ -f ".container.json" ]
then
  container_id=$(jq -r '.containerId' < .container.json)
  container_folder=$(jq -r '.remoteWorkspaceFolder' < .container.json)
fi

run_with_existing() {
  if [ -n "${container_id}" ]
  then
    $*
  else
    printf "%s" "container found. bring up the container using `devc up`"
  fi
}

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
    run_with_existing docker container exec -w "${container_folder}" -it "${container_id}" ${cmd}
    ;;
  edit)
    $EDITOR .devcontainer/devcontainer.json
    ;;
  shell)
    run_with_existing docker container exec -w "${container_folder}" -it "${container_id}" bash
    ;;
  stop)
    run_with_existing docker container stop "${container_id}"
    ;;
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
    run_with_existing docker container restart "${container_id}"
    ;;
  rebuild)
    $0 kill; $0 up
    ;;
  *)
    printf "no command specified\n"
    ;;
esac
