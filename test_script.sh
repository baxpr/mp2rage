export FSLDIR=/usr/share/fsl/5.0
bash code/mp2rage.sh \
--mp2rage_dir INPUTS/NIFTI \
--robust_beta 0 \
--project TESTPROJ --subject TESTSUBJ --session TESTSESS --scan TESTSCAN \
--outdir OUTPUTS
