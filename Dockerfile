from avelior/plink2:latest

# Maintainer
MAINTAINER Seung Hoan Choi <seuchoi@gmail.com>

RUN apt-get update
RUN apt-get -y install git

## pulling my file
RUN git clone https://github.com/broadinstitute/TOPMed_AFib_pipeline.git && cd ./TOPMed_AFib_pipeline && git pull origin master

## hope this is running....
RUN wget http://people.virginia.edu/~wc9c/KING/Linux-king.tar.gz && \
    tar -xzvf Linux-king.tar.gz && \
    cp king /bin/king

### gogogo
