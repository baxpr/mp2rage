#!/bin/bash
#
# Dependencies:
#   imagemagick
#   FSL 5.0

# Parse inputs
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
    --mp2rage_dir)
		MP2RAGE_DIR="$2"
    	shift; shift
		;;
    --project)
		PROJECT="$2"
    	shift; shift
		;;
	--subject)
		SUBJECT="$2"
		shift; shift
		;;
	--session)
		SESSION="$2"
		shift; shift
		;;
    --scan)
    	SCAN="$2"
    	shift; shift
    	;;
	--outdir)
		OUTDIR="$2"
		shift; shift
		;;
	*)
    	shift
    	;;
  esac
done

echo MP2RAGE_DIR = "${MP2RAGE_DIR}"
echo PROJECT     = "${PROJECT}"
echo SUBJECT     = "${SUBJECT}"
echo SESSION     = "${SESSION}"
echo SCAN        = "${SCAN}"
echo OUTDIR      = "${OUTDIR}"

# Set up FSL (we rely on FSLDIR being set already)
source ${FSLDIR}/etc/fslconf/fsl.sh
FSL=${FSLDIR}/bin

# Find all real input images, relying on recent default dcm2niix filename tagging
shopt -s nullglob
REALS=("${MP2RAGE_DIR}"/*_real_*.nii.gz)
echo Found ${#REALS[@]} real images
if [ ${#REALS[@]} -eq 0 ] ; then exit 1 ; fi
for f in ${REALS[@]}; do echo "   ${f}" ; done

# Get base part of filename
TMP=${REALS[0]%.nii.gz}
FBASE=${TMP%_real_t*}
echo Assuming basename "${FBASE}"

# Parse the filenames into useful bits and compute filenames of imaginary images
for n in ${!REALS[@]} ; do
	FTIME[n]=${REALS[n]#"${FBASE}"_real_t}
	FTIME[n]=${FTIME[n]%.nii.gz}
	IMAGS[n]=${FBASE}_imaginary_t${FTIME[n]}.nii.gz
	if [ ! -e ${IMAGS[n]} ] ; then
		echo Failed to find ${IMAGS[n]}
		exit 1
	else
		echo Found imaginary: ${IMAGS[n]}
	fi
done

# Re-sort by inversion time
IFS=$'\n' SFTIME=($(sort -n <<< "${FTIME[*]}")) ; unset IFS
echo "Initial list of inversion times: ${FTIME[*]}"
echo "                         Sorted: ${SFTIME[*]}"

echo Sorted images:
for n in ${!REALS[@]} ; do
	SREALS[n]="${FBASE}"_real_t"${SFTIME[n]}".nii.gz
	SIMAGS[n]="${FBASE}"_imaginary_t"${SFTIME[n]}".nii.gz
	echo "    ${SREALS[n]}"
	echo "    ${SIMAGS[n]}"
done


# Use the first two inversion times to compute the MP2RAGE

# Magnitude squared images, then mp2rage denominator
# (abs(GRE_TI1).^2 + abs(GRE_TI2).^2)
echo Computing MP2RAGE with
echo "   ${SREALS[0]}"
echo "   ${SIMAGS[0]}"
echo "   ${SREALS[1]}"
echo "   ${SIMAGS[1]}"
for n in 0 1 ; do
	MAGSQ[n]=${OUTDIR}/tmp_magsq_${SFTIME[n]}.nii.gz
	${FSL}/fslmaths ${SREALS[n]} -sqr ${OUTDIR}/tmp_rsqr
	${FSL}/fslmaths ${SIMAGS[n]} -sqr ${OUTDIR}/tmp_isqr
	${FSL}/fslmaths ${OUTDIR}/tmp_rsqr -add ${OUTDIR}/tmp_isqr ${MAGSQ[n]}
done
DENOM=${OUTDIR}/tmp_denom.nii.gz
${FSL}/fslmaths ${MAGSQ[0]} -add ${MAGSQ[1]} ${DENOM}

# Numerator, real part
# (conj(GRE_TI1).*GRE_TI2)
# (R0 - iI0) * (R1 + iI1) = R0*R1 + I0*I1 + iR0*I1 - iR1*I0
TERM1=${OUTDIR}/tmp_term1.nii.gz
${FSL}/fslmaths ${SREALS[0]} -mul ${SREALS[1]} ${TERM1}
TERM2=${OUTDIR}/tmp_term2.nii.gz
${FSL}/fslmaths ${SIMAGS[0]} -mul ${SIMAGS[1]} ${TERM2}
NUMREAL=${OUTDIR}/tmp_numreal.nii.gz
${FSL}/fslmaths ${TERM1} -add ${TERM2} ${NUMREAL}

# We don't need the imaginary part, but here is the code for it
#TERM3=${OUTDIR}/tmp_term3.nii.gz
#fslmaths ${REALS[0]} -mul ${IMAGS[1]} ${TERM3}
#TERM4=${OUTDIR}/tmp_term4.nii.gz
#fslmaths ${REALS[1]} -mul ${IMAGS[0]} ${TERM4}
#NUMIMAG=${OUTDIR}/tmp_numimag.nii.gz
#fslmaths ${TERM2} -sub ${TERM3} ${NUMIMAG}

# Compute the MP2RAGE
MP2RAGE=${OUTDIR}/mp2rage.nii.gz
${FSL}/fslmaths ${NUMREAL} -div ${DENOM} -add 1 ${MP2RAGE}


# Compute the magnitude image for the second inversion time and use BET to make
# brain mask from it
MAG1=${OUTDIR}/mag1.nii.gz
${FSL}/fslmaths ${MAGSQ[1]} -sqrt ${MAG1}
${FSL}/bet ${MAG1} ${OUTDIR}/mag1_brain -R -f 0.2 -g 0 -m

# Make masked MP2RAGE image
${FSL}/fslmaths ${MP2RAGE} -mas ${OUTDIR}/mag1_brain ${OUTDIR}/mp2rage_brain

# Make PDF
${FSL}/slicer ${MP2RAGE} ${OUTDIR}/mag1_brain_mask -l red -x 0.55 ${OUTDIR}/x.png \
    -y 0.5 ${OUTDIR}/y.png -z 0.5 ${OUTDIR}/z.png
montage -title "${PROJECT} ${SUBJECT} ${SESSION} ${SCAN}" -mode concatenate -tile 2x2 \
    ${OUTDIR}/x.png ${OUTDIR}/y.png ${OUTDIR}/z.png ${OUTDIR}/mp2rage.pdf

# Clean up
rm ${OUTDIR}/tmp*.nii.gz ${OUTDIR}/{x,y,z}.png ${OUTDIR}/mag1.nii.gz \
    ${OUTDIR}/mag1_brain.nii.gz

