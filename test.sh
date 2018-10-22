#!/bin/sh

# Run the image:
singularity run \
--bind INPUTS:/INPUTS \
--bind OUTPUTS:/OUTPUTS \
MP2RAGE_v1.0.1.simg \
--mp2rage_dir /INPUTS/NIFTI \
--project PROJNAME \
--subject SUBJNAME \
--session SESSNAME \
--scan SCANNAME

exit 0


singularity exec \
--bind INPUTS:/INPUTS \
--bind OUTPUTS:/OUTPUTS \
MP2RAGE_v1.0.1.simg \
ls /INPUTS/NIFTI
