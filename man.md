% devc(1) | General Commands

Name
====

devc - A wrapper around the devcontainer cli with extra features


Synopsis
========

devc [command] [args]

Description
===========

devc is a tool meant to extend the devcontainer cli with sensible commands that make working with devcontainers a better experience.

Options
=======

## Available commands:

`up` 

: Starts the dev-container

`exec`

: Runs a single command in the container

`background`

: Same as `exec`, but in the background

`edit`

: Opens the `.devcontainer/devcontainer.json` in your `$EDITOR`

`shell`

: Starts an interactive shell in the container at the workspace folder

`stop`

: Stops the container without removing it

`restart`

: Restarts the container without rebuilding

`kill`

: Removes the container, image, and volume for the container

`rebuild (formerly restart)`

: Equivalent to **kill** + **up**

Configuration
=============

`DEVC_SHELL`
: The default shell to use when running `devc shell`
