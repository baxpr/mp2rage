#!/bin/sh

# Build the image:
docker build . -t mp2rage:v2.0.0


# Run it like this:
# docker run \
#   --mount type=bind,src=/path/to/INPUTS,dst=/INPUTS \
#   --mount type=bind,src=/path/to/OUTPUTS,dst=/OUTPUTS \
#   mp2rage:v2.0.0
