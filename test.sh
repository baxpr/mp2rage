#!/bin/sh

# Run the image:
singularity run MP2RAGE_v1.0.1.simg \
--bind INPUTS:/INPUTS \
--bind OUTPUTS:/OUTPUTS \
--mp2rage_dir /INPUTS/NIFTI \
--project PROJNAME \
--subject SUBJNAME \
--session SESSNAME \
--scan SCANNAME
