#!/bin/bash

set -e

# start ssh
sudo service ssh start

# keep the container alive
tail -f /dev/null