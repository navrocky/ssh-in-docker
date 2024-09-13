#!/bin/sh

docker run --rm -it -v ./setup.sh:/usr/local/bin/setup.sh ubuntu setup.sh
