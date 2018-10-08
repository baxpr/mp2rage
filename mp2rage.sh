#!/bin/bash
#
# Dependencies:
#
#   imagemagick
#   FSL
#     fslmaths
#     slicer
#     bet
#       bet2
#       betsurf
#       fast
#       flirt
#       fslmerge
#       fslroi
#       fslstats
#       fslval
#         fslhd
#       immv
#       imtest
#       remove_ext
#       standard_space_roi
#         convert_xfm
#         imcp
#         ${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz
#         ${FSLDIR}/data/standard/MNI152_T1_2mm_brain_mask_dil.nii.gz

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

# Get project, subject, session, scan info
PROJ=`head -1 "${INDIR}/project"`
SUBJ=`head -1 "${INDIR}/subject"`
SESS=`head -1 "${INDIR}/session"`
SCAN=`head -1 "${INDIR}/scan"`

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
	echo "Inversion time sort ok: ${FTIME[*]}"
else
	echo "Inversion times out of order: ${FTIME[*]}"
	exit 1
fi

# Use the first two inversion times to compute the MP2RAGE

# Magnitude squared images, then mp2rage denominator
# (abs(GRE_TI1).^2 + abs(GRE_TI2).^2)
echo Computing MP2RAGE with
Echo "   ${REALS[0]}"
Echo "   ${IMAGS[0]}"
Echo "   ${REALS[1]}"
Echo "   ${IMAGS[1]}"
for n in 0 1 ; do
	MAGSQ[n]=${OUTDIR}/tmp_magsq_${FTIME[n]}.nii.gz
	fslmaths ${REALS[n]} -sqr ${OUTDIR}/tmp_rsqr
	fslmaths ${IMAGS[n]} -sqr ${OUTDIR}/tmp_isqr
	fslmaths ${OUTDIR}/tmp_rsqr -add ${OUTDIR}/tmp_isqr ${MAGSQ[n]}
done
DENOM=${OUTDIR}/tmp_denom.nii.gz
fslmaths ${MAGSQ[0]} -add ${MAGSQ[1]} ${DENOM}

# Numerator, real part
# (conj(GRE_TI1).*GRE_TI2)
# (R0 - iI0) * (R1 + iI1) = R0*R1 + I0*I1 + iR0*I1 - iR1*I0
TERM1=${OUTDIR}/tmp_term1.nii.gz
fslmaths ${REALS[0]} -mul ${REALS[1]} ${TERM1}
TERM2=${OUTDIR}/tmp_term2.nii.gz
fslmaths ${IMAGS[0]} -mul ${IMAGS[1]} ${TERM2}
NUMREAL=${OUTDIR}/tmp_numreal.nii.gz
fslmaths ${TERM1} -add ${TERM2} ${NUMREAL}

# We don't need the imaginary part, but here is the code for it
#TERM3=${OUTDIR}/tmp_term3.nii.gz
#fslmaths ${REALS[0]} -mul ${IMAGS[1]} ${TERM3}
#TERM4=${OUTDIR}/tmp_term4.nii.gz
#fslmaths ${REALS[1]} -mul ${IMAGS[0]} ${TERM4}
#NUMIMAG=${OUTDIR}/tmp_numimag.nii.gz
#fslmaths ${TERM2} -sub ${TERM3} ${NUMIMAG}

# Compute the MP2RAGE
MP2RAGE=${OUTDIR}/mp2rage.nii.gz
fslmaths ${NUMREAL} -div ${DENOM} -add 1 ${MP2RAGE}


# Compute the magnitude image for the second inversion time and use BET to make
# brain mask from it
MAG1=${OUTDIR}/mag1.nii.gz
fslmaths ${MAGSQ[1]} -sqrt ${MAG1}
bet ${MAG1} ${OUTDIR}/mag1_brain -R -f 0.2 -g 0 -m

# Make PDF
slicer ${MP2RAGE} ${OUTDIR}/mag1_brain_mask -l red -x 0.55 ${OUTDIR}/x.png \
    -y 0.5 ${OUTDIR}/y.png -z 0.5 ${OUTDIR}/z.png
montage -title "$PROJ $SUBJ $SESS $SCAN" -mode concatenate -tile 2x2 \
    ${OUTDIR}/x.png ${OUTDIR}/y.png ${OUTDIR}/z.png ${OUTDIR}/mp2rage.pdf

# Clean up
rm ${OUTDIR}/tmp*.nii.gz ${OUTDIR}/{x,y,z}.png ${OUTDIR}/mag1.nii.gz \
    ${OUTDIR}/mag1_brain.nii.gz
