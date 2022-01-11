FROM docker.io/library/ubuntu:20.04

#ENV DOWNLOAD_URL_BASE=https://your_internal_fileserver/path_to_file
ENV MSDIAL_VERSION=4.70
ENV HDF5_VERSION=1.10.8
ENV NETCDF_VERSION=4.8.1
ENV DOTNET_CLI_TELEMETRY_OPTOUT=1
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update &&\
    apt-get install -yq \
       build-essential \
       bzip2 \
       ca-certificates \
       curl \
       gcc \
       gnupg \
       libgtk2.0-0 \
       libopenmpi-dev \
       m4 \
       smbclient \
       tar \
       unzip \
       wget \
       x11-apps \
       xauth \
       xmlstarlet \
       zlib1g-dev

WORKDIR /opt

RUN curl -k -s -S -o "MsdialConsole_v${MSDIAL_VERSION}_linux.zip" "http://prime.psc.riken.jp/compms/msdial/download/repository/Linux/MsdialConsole_v"$(echo ${MSDIAL_VERSION} | tr -d '.')"_linux.zip" &&\
    unzip "MsdialConsole_v${MSDIAL_VERSION}_linux.zip" &&\
    rm MsdialConsole_v${MSDIAL_VERSION}_linux.zip &&\
    mv MSDIAL\ ver.${MSDIAL_VERSION}\ Linux MSDIAL_ver.${MSDIAL_VERSION}_Linux &&\
    chmod +x /opt/MSDIAL_ver.${MSDIAL_VERSION}_Linux/MsdialConsoleApp &&\
    ln -s /opt/MSDIAL_ver.${MSDIAL_VERSION}_Linux/MsdialConsoleApp /usr/local/bin/   

# For Build HDF5 and netcdf credits go to https://github.com/pacificclimate/docker-netcdf
# I updated the version of netcdf accordingly with Tsugawa's message

#Build HDF5
# Original source URL https://www.hdfgroup.org/package/hdf5-1-10-8-tar-gz/?wpdmdl=16059&refresh=61d3110758a151641222407
RUN curl -k -s -S -LJO "https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5-"$(echo ${HDF5_VERSION} | tr '.' '_')".tar.gz" && \
    tar xzvf hdf5-hdf5-$(echo ${HDF5_VERSION} | tr '.' '_').tar.gz &&\
    cd hdf5-hdf5-$(echo ${HDF5_VERSION} | tr '.' '_') && \
    CC=mpicc ./configure --enable-parallel --prefix=/usr/local/hdf5 && \
    make -j4 && \
    make install && \
    cd .. && \
    rm -rf hdf5-hdf5-*

RUN echo -e "# MS-DIAL libraries\n/usr/local/netcdf/lib" > /etc/ld.so.conf.d/msdial.conf &&\
    ldconfig

#Build netcdf
# Original source URL https://github.com/Unidata/netcdf-c/archive/refs/tags/v${NETCDF_VERSION}.tar.gz
# Then i renamed the file as netcdf-c-${NETCDF_VERSION}.tar.gz
RUN curl -k -s -S -LJO "https://github.com/Unidata/netcdf-c/archive/refs/tags/v${NETCDF_VERSION}.tar.gz" &&\
    tar xzvf netcdf-c-${NETCDF_VERSION}.tar.gz && \
    cd netcdf-c-${NETCDF_VERSION} && \
    ./configure --prefix=/usr/local/netcdf \ 
                CC=mpicc \
                LDFLAGS=-L/usr/local/hdf5/lib \
                CFLAGS=-I/usr/local/hdf5/include && \
    make -j4 && \
    make check &&\
    make install && \
    cd .. && \
    rm -rf netcdf-c-${NETCDF_VERSION} netcdf-c-${NETCDF_VERSION}.tar.gz

