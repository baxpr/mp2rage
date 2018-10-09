FROM ubuntu:16.04
LABEL maintainer="baxter.rogers@vanderbilt.edu"

# System packages
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get install -y \
      fsl-5.0-core \
      imagemagick

COPY . /code

CMD ["/bin/bash","-c","/code/mp2rage.sh","/INPUTS","/OUTPUTS"]
