from r-base:3.6.3


# Maintainer
MAINTAINER Seung Hoan Choi <seuchoi@gmail.com>

RUN apt-get update
RUN apt-get -y install git

## pulling my file
RUN git clone https://github.com/seuchoi/KING.git && cd ./KING && git pull origin master

## Install KING KING
RUN wget http://people.virginia.edu/~wc9c/KING/Linux-king.tar.gz && \
    tar -xzvf Linux-king.tar.gz && \
    cp king /bin/king

# Install PLINK
RUN wget http://s3.amazonaws.com/plink2-assets/plink2_linux_x86_64_20200328.zip && \
    unzip -o plink2_linux_x86_64_20200328.zip && \
    cp plink2 /bin/plink2

# install some R rpackages
RUN Rscript --vanilla /KING/install.R
