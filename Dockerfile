FROM scratch
COPY --from=qemux/qemu-docker:4.18 / /

ARG DEBCONF_NOWARNINGS "yes"
ARG DEBIAN_FRONTEND "noninteractive"
ARG DEBCONF_NONINTERACTIVE_SEEN "true"


RUN echo "deb http://deb.debian.org/debian/ bookworm main" >> /etc/apt/sources.list.d/bookworm.list

RUN echo -e "Package: *\nPin: release n=trixie\nPin-Priority: 900\nPackage: *\nPin: release n=bookworm\nPin-Priority: 400" | tee /etc/apt/preferences.d/preferences > /dev/null
RUN apt-get update \
    && apt-get --no-install-recommends -y install \
        curl \
        7zip \
        wsdd \
        samba \
        wimtools \
        dos2unix \
        cabextract \
        genisoimage \
        libxml2-utils \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./src /run/
COPY ./assets /run/assets

ADD https://raw.githubusercontent.com/christgau/wsdd/master/src/wsdd.py /usr/sbin/wsdd
ADD https://github.com/qemus/virtiso/releases/download/v0.1.248/virtio-win-0.1.248.iso /run/drivers.iso

RUN chmod +x /run/*.sh && chmod +x /usr/sbin/wsdd

EXPOSE 8006 3389
VOLUME /storage

ENV RAM_SIZE "4G"
ENV CPU_CORES "2"
ENV DISK_SIZE "64G"
ENV VERSION "win11"

ARG VERSION_ARG "0.0"
RUN echo "$VERSION_ARG" > /run/version

ENTRYPOINT ["/usr/bin/tini", "-s", "/run/entry.sh"]
