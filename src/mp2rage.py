#!/usr/bin/env python
#
# Following these:
#   https://github.com/JosePMarques/MP2RAGE-related-scripts
#   https://github.com/Gilles86/pymp2rage

import argparse
import json
import nibabel
import nilearn.image
import nilearn.masking
import numpy
import os
import sys
from pydicom import dcmread


def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('--dicom', required=True)
    parser.add_argument('--real_niigz1', required=True)
    parser.add_argument('--imag_niigz1', required=True)
    parser.add_argument('--json1', required=True)
    parser.add_argument('--real_niigz2', required=True)
    parser.add_argument('--imag_niigz2', required=True)
    parser.add_argument('--json2', required=True)
    parser.add_argument('--robust_beta', default=0.1, type=float)
    parser.add_argument('--wmnull_ms', default=670, type=float)
    parser.add_argument('--mask_fwhm', default=2.5, type=float)
    parser.add_argument('--efficiency', default=0.96, type=float)
    parser.add_argument('--out_dir', required=True)
    return parser.parse_args()


def get_pulseseq_params(json1_file, json2_file, dicom_file):
    '''
    MP2RAGE params for a specific VUIIS custom
    pulse sequence on Philips. Time units sec
    '''
    with open(json1_file, 'r') as json1_data:
        json1_prm = json.load(json1_data)
    with open(json2_file, 'r') as json2_data:
        json2_prm = json.load(json2_data)

    for check_field in [
        'RepetitionTime',
        'EchoTrainLength',
        'AcquisitionDuration',
        'MagneticFieldStrength',
        ]:
        if json1_prm[check_field] != json2_prm[check_field]:
            raise Exception(f'{check_field} does not match')

    prm = {
        'tr': json1_prm['RepetitionTime'],
        'etl': json1_prm['EchoTrainLength'],
        'acqdur': json1_prm['AcquisitionDuration'],
        'B0': json1_prm['MagneticFieldStrength'],
        }

    prm['ti'] = [json1_prm['TriggerDelayTime']/1000, json2_prm['TriggerDelayTime']/1000]
    prm['flipdeg'] = [json1_prm['FlipAngle'], json2_prm['FlipAngle']]
    prm['fliprad'] = [x / 180 * numpy.pi for x in prm['flipdeg']]

    prm['nkt'] = dcmread(dicom_file).NumberOfKSpaceTrajectories
    prm['mp2rage_tr'] = prm['acqdur'] / prm['nkt']

    return prm


def compute_mp2rage(data1, data2, beta):
    numer = numpy.real(numpy.multiply(
            numpy.conj(data1),
            data2
            )) - beta
    denom = numpy.square(numpy.abs(data1) + numpy.abs(data2)) + 2 * beta
    return numpy.divide(numer, denom)


def compute_sig_for_t1(prm, T1):
    '''
    Predict the mp2rage signal given T1 and pulse sequence parameters.
    Following
    Marques JP, Kober T, Krueger G, van der Zwaag W, Van de Moortele PF, Gruetter R. 
    MP2RAGE, a self bias-field corrected sequence for improved segmentation and 
    T1-mapping at high field. 
    Neuroimage. 2010 Jan 15;49(2):1271-81. doi: 10.1016/j.neuroimage.2009.10.002.
    PMID: 19819338.
    https://pubmed.ncbi.nlm.nih.gov/19819338/
    https://www.sciencedirect.com/science/article/pii/S1053811909010738
    Appendix A notation.
    '''
    
    TR = prm['tr']
    mp2rage_tr = prm['mp2rage_tr']
    n = prm['etl']
    ti1 = prm['ti'][0]
    ti2 = prm['ti'][1]
    a1 = prm['fliprad'][0]
    a2 = prm['fliprad'][1]
    eff = args.efficiency

    TA = ti1 - n/2*TR
    TB = (ti2 - n/2*TR) - (ti1 + n/2*TR)
    TC = mp2rage_tr - (ti2 + n/2*TR)

    E1 = numpy.exp(-TR/T1)
    EA = numpy.exp(-TA/T1)
    EB = numpy.exp(-TB/T1)
    EC = numpy.exp(-TC/T1)

    cosa1E1 = numpy.cos(a1)*E1
    cosa2E1 = numpy.cos(a2)*E1

    EBterm1 = (1-EA) * cosa1E1**n
    EBterm2 = (1-E1) * (1-cosa1E1**n) / (1-cosa1E1)
    EBterm = (EBterm1 + EBterm2) * EB
    ECterm1 = (EBterm + (1-EB)) * cosa2E1**n
    ECterm2 = (1-E1) * (1-cosa2E1**n) / (1-cosa2E1)
    ECterm = (ECterm1 + ECterm2) * EC
    numer = ECterm + (1-EC)
    denom = 1 + eff * (numpy.cos(a1)*numpy.cos(a2))**n * numpy.exp(-mp2rage_tr/T1)
    mzss = numer / denom

    sig1term1 = (-eff*mzss*EA + (1-EA)) * cosa1E1**(n/2-1)
    sig1term2 = (1-E1) * (1-cosa1E1**(n/2-1)) / (1-cosa1E1)
    sig1 = numpy.sin(a1) * (sig1term1 + sig1term2)

    sig2term1 = (mzss-(1-EC)) / (EC*cosa2E1**(n/2))
    sig2term2 = (1-E1) * (cosa2E1**(-n/2)-1) / (1-cosa2E1)
    sig2 = numpy.sin(a2) * (sig2term1 - sig2term2)
 
    sig_mp2rage = sig1 * sig2 / (sig1*sig1 + sig2*sig2)

    return(sig_mp2rage)


if __name__ == '__main__':
    
    args = parse_arguments()
    
    # Load niftis
    img1_real = nibabel.load(args.real_niigz1)
    img1_imag = nibabel.load(args.imag_niigz1)
    img2_real = nibabel.load(args.real_niigz2)
    img2_imag = nibabel.load(args.imag_niigz2)

    # Verify matching geom
    affine = img1_real.affine
    if not (affine==img1_imag.affine).all():
        raise Exception(f'Affine mismatch in {args.imag_niigz1}')
    if not (affine==img2_real.affine).all():
        raise Exception(f'Affine mismatch in {args.real_niigz2}')
    if not (affine==img2_imag.affine).all():
        raise Exception(f'Affine mismatch in {args.imag_niigz2}')        

    # Image data in complex form
    data1 = img1_real.get_fdata() + 1j * img1_imag.get_fdata()
    data2 = img2_real.get_fdata() + 1j * img2_imag.get_fdata()
    
    # Mask based on second echo magnitude
    img2_mag = nibabel.Nifti1Image(numpy.abs(data2), affine)
    img2_mag_smoothed = nilearn.image.smooth_img(img2_mag, args.mask_fwhm)
    img_mask = nilearn.masking.compute_epi_mask(img2_mag_smoothed)
    nibabel.save(img_mask, os.path.join(args.out_dir, 'mask.nii.gz'))

    # Compute beta param for robust method based on in-mask values
    denom = numpy.square(numpy.abs(data1) + numpy.abs(data2))
    img_denom = nibabel.Nifti1Image(denom, affine)
    denom_mean = numpy.mean(nilearn.masking.apply_mask(img_denom, img_mask))
    beta_scaled = args.robust_beta * denom_mean

    # Compute regular MP2RAGE "UNI" [-0.5,0.5]
    mp2rage = compute_mp2rage(data1, data2, 0)
    img_mp2rage = nibabel.Nifti1Image(mp2rage, affine)
    nibabel.save(img_mp2rage, os.path.join(args.out_dir, 'mp2rage.nii.gz'))
    
    # Mask out the low signal voxels (set to -0.5)
    #mmp2rage = (
    #    numpy.multiply(mp2rage, img_mask.get_fdata()) -
    #    (1 - img_mask.get_fdata()) * 0.5
    #    )
    #img_mmp2rage = nibabel.Nifti1Image(mmp2rage, affine)
    #nibabel.save(img_mmp2rage, os.path.join(args.out_dir, 'mp2rage_masked.nii.gz'))
    
    # Compute robust T1W and shift to [0,1] for sane viewer behavior
    rmp2rage = compute_mp2rage(data1, data2, beta_scaled)
    rmp2rage = rmp2rage + 0.5
    img_rmp2rage = nibabel.Nifti1Image(rmp2rage, affine)
    nibabel.save(img_rmp2rage, os.path.join(args.out_dir, 'mp2rage_robust.nii.gz'))

    # Compute T1 from UNI. Mask and save to file
    params = get_pulseseq_params(args.json1, args.json2, args.dicom)
    ref_t1 = numpy.arange(0.05, 5, 0.05)
    ref_signal = numpy.array([compute_sig_for_t1(params, x) for x in ref_t1])
    inds = numpy.argsort(ref_signal)
    ref_signal = ref_signal[inds]
    ref_t1 = ref_t1[inds]
    t1data = numpy.interp(mp2rage, ref_signal, ref_t1, left=5, right=0)
    img_t1 = nibabel.Nifti1Image(
        numpy.multiply(t1data, img_mask.get_fdata()),
        affine
        )
    nibabel.save(img_t1, os.path.join(args.out_dir, 'quant_t1.nii.gz'))

    # Estimate white matter nulled image from T1
    img_wmn = nibabel.Nifti1Image(
        numpy.abs(1 - 2 * numpy.exp(-numpy.reciprocal(t1data)*args.wmnull_ms/1000)),
        affine
        )
    nibabel.save(img_wmn, os.path.join(args.out_dir, 'white_matter_nulled.nii.gz'))

