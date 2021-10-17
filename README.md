# circleci-diag

[![CircleCI](https://circleci.com/gh/RandomiDn/circleci.svg?style=shield&circle-token=b7f096ed35d60d90f0c6723201538ef3a1619c67)](https://circleci.com/gh/RandomiDn/circleci)

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

