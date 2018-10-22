#!/bin/sh

# Build the image:
sudo singularity build MP2RAGE_v1.0.1.simg Singularity


# Run it like this:
singularity run MP2RAGE_v1.0.1.simg \
--bind INPUTS:/INPUTS \
--bind OUTPUTS:/OUTPUTS \
--mp2rage_dir /INPUTS/NIFTI \
--project PROJNAME \
--subject SUBJNAME \
--session SESSNAME \
--scan SCANNAME
