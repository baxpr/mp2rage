FROM ubuntu:16.04
LABEL maintainer="baxter.rogers@vanderbilt.edu"

# System packages
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y \
      fsl-5.0-core \
      imagemagick
	  
# Fix imagemagick policy to allow PDF output. See https://usn.ubuntu.com/3785-1/
RUN sed -i 's/rights="none" pattern="PDF"/rights="read | write" pattern="PDF"/' \
	    /etc/ImageMagick-6/policy.xml

# Get the specific codebase		
COPY . /code

CMD ["/bin/bash","-c","/code/mp2rage.sh","/INPUTS","/OUTPUTS"]
