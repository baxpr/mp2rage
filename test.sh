#!/bin/sh

# Run the image:
singularity run \
--bind INPUTS:/INPUTS \
--bind OUTPUTS:/OUTPUTS \
baxpr-mp2rage-master-v1.0.1.simg \
--mp2rage_dir /INPUTS/NIFTI \
--project PROJNAME \
--subject SUBJNAME \
--session SESSNAME \
--scan SCANNAME
