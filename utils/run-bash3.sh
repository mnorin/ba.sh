#!/usr/bin/env bash

# Official bash container
# Change directory to the one with your code
# and then run this script
docker run -it --rm -v $(pwd):/code bash:3.2 /usr/local/bin/bash

