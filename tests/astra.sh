#!/bin/sh

docker run --rm -it -v ./setup.sh:/usr/local/bin/setup.sh harbor.rnds.pro/rnds/astra_linux_se_smolensk:1.7.5-slim setup.sh
