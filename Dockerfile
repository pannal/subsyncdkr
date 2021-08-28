########################################################################################
# builder image                                                                        #
########################################################################################

FROM python:3.8-slim AS builder

# Set the working directory to /app
WORKDIR /app
ARG DEBIAN_FRONTEND=noninteractive
RUN ln -s /usr/bin/dpkg-split /usr/sbin/dpkg-split && ln -s /usr/bin/dpkg-deb /usr/sbin/dpkg-deb && ln -s /bin/tar /usr/sbin/tar && ln -s /bin/rm /usr/sbin/rm
RUN apt-get update \
    && apt-get install -y \
        apt-utils \
        gcc \
        g++ \
        build-essential libssl-dev libffi-dev python-dev python3-pip python3-dev cargo git swig libpulse-dev libasound2-dev libsphinxbase3 libsphinxbase-dev libpocketsphinx-dev libavdevice-dev ffmpeg \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install -U pip && git clone https://github.com/sc0ty/subsync.git && cd subsync && cp subsync/config.py.template subsync/config.py


# Install any needed packages specified in requirements.txt; build subsync
RUN pip install --trusted-host pypi.python.org -r subsync/requirements.txt && pip install pyinstaller && pip install ./subsync

WORKDIR /app/subsync

# if anything major changes, we'll use our own spec; for now dynamically generate it
#COPY subsync.spec .
RUN pyinstaller bin/subsync && pyinstaller -y subsync.spec

########################################################################################
# actual image                                                                         #
########################################################################################

FROM python:3.8-slim
COPY --from=builder /app/subsync/dist/subsync /app
RUN ln -s /app/subsync /usr/bin/subsync

# install non-def deps
RUN apt-get update \
    && apt-get install -y libdrm-dev libxcb1-dev

# cleanup
RUN rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["subsync", "--cli"]