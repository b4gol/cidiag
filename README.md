# circleci-diag

[![CircleCI](https://circleci.com/gh/RandomiDn/circleci.svg?style=shield&circle-token=c0b18eac97c20221b618fcdcbb0be80966ea2042)](https://circleci.com/gh/RandomiDn/circleci)

Bash script to run diag commands in a build

## Supported OS

Uses `uname -s` to fetch OS

* Linux
* Darwin

## Modules

### OS

* Runs `ps aux` on both Darwin and Linux

### Package

* Runs `dpkg -l` on Linux
* Runs `brew list --versions` on Darwin

