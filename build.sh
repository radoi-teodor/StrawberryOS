#!/bin/bash

# setam variabilele de mediu pentru compilare
export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

# executam make
make all