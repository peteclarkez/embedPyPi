FROM balenalib/raspberry-pi-debian AS base

####

FROM base AS anaconda

ENV CONDAHOME=/opt/miniconda

# Install conda for scientific python
RUN apt-get update && \
  apt-get install -y wget && \
  wget https://repo.continuum.io/miniconda/Miniconda3-3.16.0-Linux-armv7l.sh -O miniconda.sh
#2015-08-24

#  apt-get purge wget && \
RUN apt-get install bzip2 && \
  bash miniconda.sh -b -p $CONDAHOME && \ 
  export PATH="$CONDAHOME/bin:$PATH" && \
  rm miniconda.sh && \
  # Add Raspberry Pi channel for conda installations
  $CONDAHOME/bin/conda config --add channels rpi && \ 
  # Update conda
  $CONDAHOME/bin/conda update  -y conda && \
  $CONDAHOME/bin/conda install -y pip

ENV PATH=/opt/miniconda/bin:$PATH

# This upgrade step curently fails for Miniconda ARM
#RUN $CONDAHOME/bin/conda install -y python=3.6 -c rpi

####

FROM anaconda AS embedpy

ARG embedpy_url=https://github.com/KxSystems/embedPy.git
ARG embedpy_tag=1.1

RUN apt-get -yy --option=Dpkg::options::=--force-unsafe-io --no-install-recommends install \
		git build-essential \
		ca-certificates \
		curl \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

RUN git clone https://github.com/KxSystems/embedPy.git
RUN mkdir -p /opt/kx/embedPy && cp embedPy/makefile embedPy/p.* embedPy/py.* /opt/kx/embedPy/
# Following sed command is replacing change made in the following pull request
# https://github.com/KxSystems/embedPy/pull/88
RUN sed -i 's/\+\=/\:\=/g' /opt/kx/embedPy/makefile
RUN make -C /opt/kx/embedPy p.so

####

FROM anaconda

ARG VCS_REF=dev
ARG BUILD_DATE=dev

LABEL	org.label-schema.schema-version="1.0" \
	org.label-schema.name=embedPy \
	org.label-schema.description="Allows the kdb+ interpreter to call Python functions in Raspberry Pi" \
	org.label-schema.vendor="Clarkez" \
	org.label-schema.license="Apache-2.0" \
	org.label-schema.url="https://github.com/peteclarkez/embedpy-rpi" \
	org.label-schema.version="${VERSION:-dev}" \
	org.label-schema.vcs-url="git@github.com:peteclarkez/embedpy-rpi.git" \
	org.label-schema.vcs-ref="$VCS_REF" \
	org.label-schema.build-date="$BUILD_DATE" \
	org.label-schema.docker.cmd="docker run peteclarkez/embedpy-rpi"

RUN apt-get -yy --option=Dpkg::options::=--force-unsafe-io --no-install-recommends install \
		ca-certificates \
		curl \
		rlwrap \
		runit \
		unzip \
	&& apt-get clean \
	&& find /var/lib/apt/lists -type f -delete

RUN passwd -d root
RUN useradd -s /bin/bash -U -m kx

ENV QHOME=/opt/kx/q
ENV PATH=/opt/miniconda/bin:$PATH

RUN mkdir -p $QHOME

ARG L32ARM_URL=https://kx.com/wp-content/uploads/2020/10/linuxarm.zip
ARG L32ARM_SHA256=67f112587159883a7966418c411f10ab4950558084a4971e3ec6ec284c486a21

RUN curl -f -o /tmp/linuxarm.zip -L $L32ARM_URL \
	&& [ "$L32ARM_SHA256" = "$(sha256sum /tmp/linuxarm.zip | cut -b1-64)" ]

# If the URL stops working, place linuxarm manually in this folder 
# and swap the following command for the previous one 
#COPY l32arm/linuxarm.zip /tmp

RUN unzip -d /opt/kx /tmp/linuxarm.zip \
	&& rm /tmp/linuxarm.zip \
    && ln -s $QHOME/l32arm $QHOME/l32 \
	&& apt-get -yy --option=Dpkg::options::=--force-unsafe-io purge unzip

COPY docker/q.wrapper /usr/local/bin/q

COPY --from=embedpy /opt/kx/embedPy /opt/kx/embedPy
RUN ln -s -t $QHOME/l32 /opt/kx/embedPy/l32/p.so \
	&& ln -s -t $QHOME /opt/kx/embedPy/p.q /opt/kx/embedPy/p.k

RUN $CONDAHOME/bin/conda create  -y -n kx python=3 --no-default-packages

RUN chmod a+x /usr/local/bin/q

COPY docker/profile.sh /etc/profile.d/kx.sh
RUN cat /etc/profile.d/kx.sh >> /root/.bashrc

COPY docker/init /init
RUN chmod a+x /init

ENTRYPOINT ["/init"]
CMD ["q"]