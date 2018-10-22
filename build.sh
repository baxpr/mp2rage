#!/bin/sh

# Build the image:
sudo singularity build MP2RAGE_v1.0.1.simg Singularity


# Run it like this:
# docker run \
#   --mount type=bind,src=/path/to/INPUTS,dst=/INPUTS \
#   --mount type=bind,src=/path/to/OUTPUTS,dst=/OUTPUTS \
#   mp2rage:v2.0.0
