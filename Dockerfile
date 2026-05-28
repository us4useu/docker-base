#     ██████████      ███████                     
#    ▒▒███▒▒▒▒███   ███▒▒▒▒▒███                   
#     ▒███   ▒▒███ ███     ▒▒███                  
#     ▒███    ▒███▒███      ▒███                  
#     ▒███    ▒███▒███      ▒███                  
#     ▒███    ███ ▒▒███     ███                   
#     ██████████   ▒▒▒███████▒                    
#    ▒▒▒▒▒▒▒▒▒▒      ▒▒▒▒▒▒▒                      
#                                                                                
#                                                 
#     ██████   █████    ███████    ███████████    
#    ▒▒██████ ▒▒███   ███▒▒▒▒▒███ ▒█▒▒▒███▒▒▒█    
#     ▒███▒███ ▒███  ███     ▒▒███▒   ▒███  ▒     
#     ▒███▒▒███▒███ ▒███      ▒███    ▒███        
#     ▒███ ▒▒██████ ▒███      ▒███    ▒███        
#     ▒███  ▒▒█████ ▒▒███     ███     ▒███        
#     █████  ▒▒█████ ▒▒▒███████▒      █████       
#    ▒▒▒▒▒    ▒▒▒▒▒    ▒▒▒▒▒▒▒       ▒▒▒▒▒        
#                                                 
#                                                 
#      █████████  █████   █████ █████ ███████████ 
#     ███▒▒▒▒▒███▒▒███   ▒▒███ ▒▒███ ▒▒███▒▒▒▒▒███
#    ▒███    ▒▒▒  ▒███    ▒███  ▒███  ▒███    ▒███
#    ▒▒█████████  ▒███████████  ▒███  ▒██████████ 
#     ▒▒▒▒▒▒▒▒███ ▒███▒▒▒▒▒███  ▒███  ▒███▒▒▒▒▒▒  
#     ███    ▒███ ▒███    ▒███  ▒███  ▒███        
#    ▒▒█████████  █████   █████ █████ █████       
#     ▒▒▒▒▒▒▒▒▒  ▒▒▒▒▒   ▒▒▒▒▒ ▒▒▒▒▒ ▒▒▒▒▒        
#
# Reason: Uses unstable, in-development pydevops from git instead of pip

ARG TARGETPLATFORM
FROM --platform=$TARGETPLATFORM nvidia/cuda:11.7.1-devel-ubuntu22.04

ARG TARGETPLATFORM

RUN echo "PLATFORM $TARGETPLATFORM"

LABEL maintainer="us4us ltd. <support@us4us.eu>"
USER root

WORKDIR /tmp

# Settings
ENV CMAKE_VERSION=4.3.3
ENV CLANG_VERSION=22

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC
# Install requirements
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    python3 \
    python3-dev \
    python3-pip \
    wget \
    git \
    vim \
    patchelf \
    g++-9 \
    doxygen \
    latexmk \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-font-utils \
    ghostscript \
    curl \
    makeself \
    debhelper \
    dkms \
    lsb-release \
    software-properties-common \
    gnupg \
    dh-dkms

RUN echo "alias python=python3" >> /root/.bashrc

# Cmake
COPY scripts/install_cmake.sh .
RUN chmod +x install_cmake.sh && ./install_cmake.sh $TARGETPLATFORM

# Clang
COPY scripts/install_clang.sh .
RUN chmod +x install_clang.sh && ./install_clang.sh
RUN echo "export CC=/usr/bin/clang-$CLANG_VERSION" >> /root/.bashrc
RUN echo "export CXX=/usr/bin/clang++-$CLANG_VERSION" >> /root/.bashrc
RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    libc++-$CLANG_VERSION-dev \
    libc++abi-$CLANG_VERSION-dev

# Copy the devenv setup script to the container
COPY scripts/devenv_setup.sh /root/devenv_setup.sh
RUN chmod +x /root/devenv_setup.sh

# Swig
RUN apt-get update && apt-get install -yq --no-install-recommends libpcre3-dev \
 && wget https://github.com/us4useu/swig/releases/download/v4.0.2/swig-4.0.2.tar.gz -O swig-4.0.2.tar.gz \
 && tar -xvf swig-4.0.2.tar.gz && cd swig-4.0.2 \
 && ./configure && make && make install

# Python dependencies and conan
RUN python3 -m pip install virtualenv \
    setuptools==67.8.0 \
    wheel==0.36.2 \
    Jinja2==3.0.3 \
    sphinx==3.3.1 \
    sphinx_rtd_theme==0.5.0 \
    six==1.16.0 \
    breathe==4.33.1 \
    docutils==0.16 \
    "git+https://github.com/pjarosik/matlabdomain@master#egg=sphinxcontrib-matlabdomain" \
    "git+https://github.com/us4useu/pydevops@clang-dev" \
    && python3 -m pip install conan

WORKDIR /

ENTRYPOINT ["/bin/bash"]
