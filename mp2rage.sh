#!/bin/bash

# Get input and output directories from the command line if given
if [ "$#" -eq 2 ]; then
    INDIR="${1}"
	OUTDIR="${2}"
else
	INDIR=/INPUTS
	OUTDIR=/OUTPUTS
fi
echo Input directory is "${INDIR}"
echo Output directory is "${OUTDIR}"

# Find all real input images, relying on recent default dcm2niix filename tagging
shopt -s nullglob
REALS=("${INDIR}"/*_real_*.nii.gz)
echo Found ${#REALS[@]} real images
if [ ${#REALS[@]} -eq 0 ] ; then exit 1 ; fi
for f in ${REALS[@]}; do echo "   ${f}" ; done

# Parse the filenames into useful bits and compute filenames of imaginary images
for n in ${!REALS[@]} ; do
	TMP=${REALS[n]%.nii.gz}
	FBASE[n]=${TMP%_real_t????}
	FTIME[n]=${TMP#*_real_}
	unset TMP
	IMAGS[n]=${FBASE[n]}_imaginary_${FTIME[n]}.nii.gz
	if [ ! -e ${IMAGS[n]} ] ; then
		echo Failed to find ${IMAGS[n]}
		exit 1
	else
		echo Found imaginary: ${IMAGS[n]}
	fi
done

# Check that we are sorted by inversion time
if IFS=$'\n' sort -c <<<"${FTIME[*]}" ; then
	echo Time sort ok
else
	echo Time sort failed
	exit 1
fi

# Use the first two inversion times to compute the MP2RAGE

# Magnitude squared images, then mp2rage denominator
# (abs(GRE_TI1).^2 + abs(GRE_TI2).^2)
for n in 0 1 ; do
	MAGSQ[n]=${OUTDIR}/tmp_magsq_${FTIME[n]}.nii.gz
	fslmaths ${REALS[n]} -sqr ${OUTDIR}/tmp_rsqr
	fslmaths ${IMAGS[n]} -sqr ${OUTDIR}/tmp_isqr
	fslmaths ${OUTDIR}/tmp_rsqr -add ${OUTDIR}/tmp_isqr ${MAGSQ[n]}
done
DENOM=${OUTDIR}/tmp_denom.nii.gz
fslmaths ${MAGSQ[0]} -add ${MAGSQ[1]} ${DENOM}

# Numerator
# (conj(GRE_TI1).*GRE_TI2)
# (R0 - I0) * (R1 + I1) = R0*R1 + R0*I1 - R1*I0 - I0*I1 
# = (R1 + I1) * R0   -   (R1 + I1) * I0
TERM1=${OUTDIR}/tmp_term1.nii.gz
fslmaths ${REALS[1]} -add ${IMAGS[1]} -mul ${REALS[0]} ${TERM1}
TERM2=${OUTDIR}/tmp_term2.nii.gz
fslmaths ${REALS[1]} -add ${IMAGS[1]} -mul ${IMAGS[0]} ${TERM2}
NUM=${OUTDIR}/tmp_num.nii.gz
fslmaths ${TERM1} -sub ${TERM2} ${NUM}

# MP2RAGE
MP2RAGE=${OUTDIR}/mp2rage.nii.gz
fslmaths ${NUM} -div ${DENOM} -add 1 ${MP2RAGE}

# Clean up
#rm ${OUTDIR}/tmp*.nii.gz

# View
#fslview -m ortho mp2rage.nii.gz -b 0,2