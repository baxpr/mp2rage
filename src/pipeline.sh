#!/usr/bin/env bash
#
# MP2RAGE pipeline

# Defaults
export out_dir=/OUTPUTS
export label=""
export robust_beta=0.1
export wmnull_ms=670
export mask_fwhm=2.5
export efficiency=0.96

# Parse inputs
while [[ $# -gt 0 ]]
do
  key="$1"
  case $key in
      --dicom)        export dicom="$2"; shift; shift;;
      --real_niigz1)  export real_niigz1="$2"; shift; shift;;
      --imag_niigz1)  export imag_niigz1="$2"; shift; shift;;
      --json1)        export json1="$2"; shift; shift;;
      --real_niigz2)  export real_niigz2="$2"; shift; shift;;
      --imag_niigz2)  export imag_niigz2="$2"; shift; shift;;
      --json2)        export json2="$2"; shift; shift;;
      --robust_beta)  export robust_beta="$2"; shift; shift;;
      --wmnull_ms)    export wmnull_ms="$2"; shift; shift;;
      --robust_beta)  export robust_beta="$2"; shift; shift;;
      --mask_fwhm)    export mask_fwhm="$2"; shift; shift;;
      --efficiency)   export efficiency="$2"; shift; shift;;
      --label)        export label="$2"; shift; shift;;
      --out_dir)      export out_dir="$2"; shift; shift;;
    *)
		echo "Unknown argument $key"; shift;;
  esac
done

# Pass command line args to mp2rage code
mp2rage.py \
    --dicom "${dicom}" \
    --real_niigz1 "${real_niigz1}" \
    --imag_niigz1 "${imag_niigz1}" \
    --json1 "${json1}" \
    --real_niigz2 "${real_niigz2}" \
    --imag_niigz2 "${imag_niigz2}" \
    --json2 "${json2}" \
    --robust_beta "${robust_beta}" \
    --wmnull_ms "${wmnull_ms}" \
    --mask_fwhm "${mask_fwhm}" \
    --efficiency "${efficiency}" \
    --out_dir "${out_dir}"

# Make output PDF
xwrapper.sh make_pdf.sh

