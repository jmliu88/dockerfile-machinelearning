FROM nvidia/cuda:7.5-cudnn4-runtime

MAINTAINER Jiaming Liu 

ENV DEBIAN_FRONTEND noninteractive
ENV LANG C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN locale-gen "en_US.UTF-8" && dpkg-reconfigure locales

# Install dependencies
RUN apt-get update && apt-get install -y \
  build-essential gcc g++ curl wget openssl ca-certificates cmake pkg-config git python-software-properties \
  libreadline-dev \
  libssl-dev \
  libbz2-dev libhdf5-dev \
  libglib2.0-0 \
  gfortran \
  imagemagick libfreetype6-dev libpng-dev libjpeg-dev \
  libopenblas-dev libatlas-dev liblapack-dev \
  libxext6 \
  libsm6 \
  libx11-dev libxrender1 \
  ncurses-dev \
  libqt4-core libqt4-dev \
  libzmq3-dev unzip gnuplot && \
  echo 'cacert=/etc/ssl/certs/ca-certificates.crt' > /root/.curlrc

# Install anaconda3

RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    #curl -Ls https://repo.continuum.io/archive/Anaconda3-4.0.0-Linux-x86_64.sh -o /tmp/Anaconda3-4.0.0-Linux-x86_64.sh && \
    #/bin/bash /tmp/Anaconda3-4.0.0-Linux-x86_64.sh -b -p /opt/conda && \
    curl -Ls https://repo.continuum.io/archive/Anaconda2-7.0.0-Linux-x86_64.sh -o /tmp/Anaconda2-7.0.0-Linux-x86_64.sh && \
    /bin/bash /tmp/Anaconda2-7.0.0-Linux-x86_64.sh -b -p /opt/conda && \
    conda update --all -y

# Install additional python components
RUN pip install -U gensim

# Clone repositories
RUN git clone git://github.com/Theano/Theano.git /usr/src/theano && \
  git clone https://github.com/torch/distro.git /usr/src/torch --recursive && \
  git clone https://github.com/scikit-learn/scikit-learn.git /usr/src/scikit-learn && \
  git clone https://github.com/pfnet/chainer.git /usr/src/chainer && \
  git clone https://github.com/fchollet/keras.git /usr/src/keras && \
  git clone https://github.com/Lasagne/Lasagne.git /usr/src/Lasagne && \

# Theano
RUN cd /usr/src/theano && python setup.py install && \
  cd /usr/src/torch; ./install.sh && \
  pip install scikit-learn scikit-image chainer keras Lasagne

# Add runner script
COPY runner.sh /usr/src/app/runner.sh
RUN chmod +x /usr/src/app/runner.sh

WORKDIR /usr/src/app
VOLUME /usr/src/app

ENTRYPOINT ["/usr/src/app/runner.sh"]
