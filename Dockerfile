# Start with FSL, ImageMagick, python3/pandas base docker
FROM baxterprogers/fsl-base:v6.0.5.2

# Update python modules
pip3 install nibabel nilearn pydicom

# Copy the pipeline code
COPY src /opt/mp2rage/src
COPY README.md /opt/mp2rage/README.md

# Add pipeline to system path
ENV PATH /opt/mp2rage/src:${PATH}

# Entrypoint
ENTRYPOINT ["pipeline.sh"]
