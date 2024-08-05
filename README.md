# mp2rage

Reconstructs a T1-weighted image and a quantitative T1 from MPRAGE images at two inversion times following Marques et al. 2010. The robust adjustment (beta factor) of O'Brien 2014 and the white matter nulled image described by Metere 2017 are also implemented.


**Marques JP, Kober T, Krueger G, van der Zwaag W, Van de Moortele PF, Gruetter  R. MP2RAGE, a self bias-field corrected sequence for improved segmentation and T1-mapping at high field. Neuroimage. 2010 Jan 15;49(2):1271-81. doi:10.1016/j.neuroimage.2009.10.002. PMID: 19819338.**

https://www.ncbi.nlm.nih.gov/pubmed/19819338

The large spatial inhomogeneity in transmit B(1) field (B(1)(+)) observable in human MR images at high static magnetic fields (B(0)) severely impairs image quality. To overcome this effect in brain T(1)-weighted images, the MPRAGE sequence was modified to generate two different images at different inversion times, MP2RAGE. By combining the two images in a novel fashion, it was possible to create T(1)-weighted images where the result image was free of proton density contrast, T(2) contrast, reception bias field, and, to first order, transmit field inhomogeneity. MP2RAGE sequence parameters were optimized using Bloch equations to maximize contrast-to-noise ratio per unit of time between brain tissues and minimize the effect of B(1)(+) variations through space. Images of high anatomical quality and excellent brain tissue differentiation suitable for applications such as segmentation and voxel-based morphometry were obtained at 3 and 7 T. From such T(1)-weighted images, acquired within 12 min, high-resolution 3D T(1) maps were routinely calculated at 7 T with sub-millimeter voxel resolution (0.65-0.85 mm isotropic). T(1) maps were validated in phantom experiments. In humans, the T(1) values obtained at 7 T were 1.15+/-0.06 s for white matter (WM) and 1.92+/-0.16 s for grey matter (GM), in good agreement with literature values obtained at lower spatial resolution. At 3 T, where whole-brain acquisitions with 1 mm isotropic voxels were acquired in 8 min, the T(1) values obtained (0.81+/-0.03 s for WM and 1.35+/-0.05 for GM) were once again found to be in very good agreement with values in the literature.


**Metere R, Kober T, Möller HE, Schäfer A. Simultaneous Quantitative MRI Mapping of T1, T2* and Magnetic Susceptibility with Multi-Echo MP2RAGE. PLoS One. 2017 Jan 12;12(1):e0169265. doi: 10.1371/journal.pone.0169265. PMID: 28081157; PMCID: PMC5230783.**

https://pubmed.ncbi.nlm.nih.gov/33270943/

Purpose: Thalamic nuclei are largely invisible in conventional MRI due to poor contrast. Thalamus Optimized Multi-Atlas Segmentation (THOMAS) provides automatic segmentation of 12 thalamic nuclei using white-matter-nulled (WMn) Magnetization Prepared Rapid Gradient Echo (MPRAGE) sequence at 7T, but increases overall scan duration. Routinely acquired, bias-corrected Magnetization Prepared 2 Rapid Gradient Echo (MP2RAGE) sequence yields superior tissue contrast and quantitative T1 maps. Application of THOMAS to MP2RAGE has been investigated in this study.

Methods: Eight healthy volunteers and five pediatric-onset multiple sclerosis patients were recruited at Children's Hospital of Philadelphia and scanned at Siemens 7T with WMn-MPRAGE and multi-echo-MP2RAGE (ME-MP2RAGE) sequences. White-matter-nulled contrast was synthesized (MP2-SYN) from T1 maps from ME-MP2RAGE sequence. Thalamic nuclei were segmented using THOMAS joint label fusion algorithm from WMn-MPRAGE and MP2-SYN datasets. THOMAS pipeline was modified to use majority voting to segment bias corrected T1-weighted uniform (MP2-UNI) images. Thalamic nuclei from MP2-SYN and MP2-UNI images were evaluated against corresponding nuclei obtained from WMn-MPRAGE images using dice coefficients, volume similarity indices (VSIs) and distance between centroids.

Results: For MP2-SYN, dice > 0.85 and VSI > 0.95 was achieved for five larger nuclei and dice > 0.6 and VSI > 0.7 was achieved for seven smaller nuclei. The dice and VSI were slightly higher, whereas the distance between centroids were smaller for MP2-SYN compared to MP2-UNI, indicating improved performance using the MP2-SYN image.

Conclusions: THOMAS algorithm can successfully segment thalamic nuclei in MP2RAGE images with essentially equivalent quality as WMn-MPRAGE, widening its applicability in studies focused on thalamic involvement in aging and disease.


**O'Brien KR, Kober T, Hagmann P, et al. Robust T1-weighted Structural Brain Imaging and Morphometry at 7T Using MP2RAGE PLoS One. 2014;9(6):e99676. Published 2014 Jun 16. doi:10.1371/journal.pone.0099676**

https://pubmed.ncbi.nlm.nih.gov/24932514/

Purpose: To suppress the noise, by sacrificing some of the signal homogeneity for numerical stability, in uniform T1 weighted (T1w) images obtained with the magnetization prepared 2 rapid gradient echoes sequence (MP2RAGE) and to compare the clinical utility of these robust T1w images against the uniform T1w images.

Materials and methods: 8 healthy subjects (29.0 ± 4.1 years; 6 Male), who provided written consent, underwent two scan sessions within a 24 hour period on a 7T head-only scanner. The uniform and robust T1w image volumes were calculated inline on the scanner. Two experienced radiologists qualitatively rated the images for: general image quality; 7T specific artefacts; and, local structure definition. Voxel-based and volume-based morphometry packages were used to compare the segmentation quality between the uniform and robust images. Statistical differences were evaluated by using a positive sided Wilcoxon rank test.

Results: The robust image suppresses background noise inside and outside the skull. The inhomogeneity introduced was ranked as mild. The robust image was significantly ranked higher than the uniform image for both observers (observer 1/2, p-value = 0.0006/0.0004). In particular, an improved delineation of the pituitary gland, cerebellar lobes was observed in the robust versus uniform T1w image. The reproducibility of the segmentation results between repeat scans improved (p-value = 0.0004) from an average volumetric difference across structures of ≈ 6.6% to ≈ 2.4% for the uniform image and robust T1w image respectively.

Conclusions: The robust T1w image enables MP2RAGE to produce, clinically familiar T1w images, in addition to T1 maps, which can be readily used in uniform morphometry packages.

