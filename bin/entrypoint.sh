#!/bin/bash

set -e

# start ssh
sudo service ssh start

# TODO should we really keep bloop running all the time?
# start bloop
~/.bloop/bloop server &>/dev/null &

# keep the container alive
bash -c "exec -a stay-up tail -f /dev/null"
