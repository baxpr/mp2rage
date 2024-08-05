#!/usr/bin/env bash

src/mp2rage.py \
    --real_niigz1 INPUTS/301_radMP2RAGE_real_t705.nii.gz \
    --imag_niigz1 INPUTS/301_radMP2RAGE_imaginary_t705.nii.gz \
    --json1 INPUTS/301_radMP2RAGE_imaginary_t705.json \
    --real_niigz2 INPUTS/301_radMP2RAGE_real_t2628.nii.gz \
    --imag_niigz2 INPUTS/301_radMP2RAGE_imaginary_t2628.nii.gz \
    --json2 INPUTS/301_radMP2RAGE_real_t2628.json \
    --dicom INPUTS/301_radMP2RAGE.dcm \
    --out_dir OUTPUTS \
    --wmnull_ms 670

