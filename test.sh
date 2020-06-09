#!/bin/sh

# Test within the image
/opt/code/mp2rage.sh \
--mp2rage_dir /INPUTS/NIFTI \
--robust_beta 0.1 \
--outdir /OUTPUTS



exit 0


# Run the image:
singularity run \
--bind INPUTS:/INPUTS \
--bind OUTPUTS:/OUTPUTS \
baxpr-mp2rage-master-v1.0.2.simg \
--mp2rage_dir /INPUTS/NIFTI \
--project PROJNAME \
--subject SUBJNAME \
--session SESSNAME \
--scan SCANNAME

exit 0

# Shell into the image
singularity shell \
--bind `pwd`:/opt \
--bind INPUTS:/INPUTS \
--bind OUTPUTS:/OUTPUTS \
baxpr-mp2rage-master-v2.0.0.simg