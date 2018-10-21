Bootstrap: docker
From: ubuntu:16.04

%files
  . /code

%labels
  Name MP2RAGE_v1.0.1
  Maintainer baxter.rogers@vanderbilt.edu

%post
  apt-get update
  apt-get install -y --no-install-recommends apt-utils
  apt-get install -y fsl-5.0-core imagemagick
	  
  # Fix imagemagick policy to allow PDF output. See https://usn.ubuntu.com/3785-1/
  sed -i 's/rights="none" pattern="PDF"/rights="read | write" pattern="PDF"/' \
    /etc/ImageMagick-6/policy.xml

  # Create input/output directories for binding
  mkdir /INPUTS && mkdir /OUTPUTS

%runscript
  cd /code && \
    xvfb-run --server-num=$(($$ + 99)) \
    --server-args='-screen 0 1600x1200x24 -ac +extension GLX' \
    bash -c /code/mp2rage.sh "$@"
