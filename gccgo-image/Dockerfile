FROM gccgo-base-image

RUN apt-get -y update
RUN apt-get -y install build-essential libgmp-dev libgmp3-dev libmpfr-dev libmpc-dev flex subversion curl

WORKDIR /work
RUN svn co -q --revision 217944 svn://gcc.gnu.org/svn/gcc/trunk src

# GCC Bug 63733 - https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63733
RUN cd /work/src && curl 'https://gcc.gnu.org/bugzilla/attachment.cgi?id=33966&action=diff&context=patch&collapsed=&headers=1&format=raw' | sed 's/[.]orig//' | patch -p2

WORKDIR /work/bld
RUN ../src/configure --enable-threads=posix --enable-shared --enable-__cxa_atexit --enable-languages=c,c++,go --enable-secureplt --enable-checking=yes --with-long-double-128 --enable-decimal-float --disable-bootstrap --disable-alsa --disable-multilib --prefix=/usr/local/gccgo
RUN make
RUN make install
RUN mkdir /usr/local/gccgo/src
RUN cp -R ../src/libgo/go /usr/local/gccgo/src/pkg
ENV PATH /usr/local/gccgo/bin:$PATH
RUN echo /usr/local/gccgo/lib64 > /etc/ld.so.conf.d/gccgo.conf
RUN ldconfig

COPY ./patches /work
RUN curl -sSL https://golang.org/dl/go1.3.3.src.tar.gz | tar -v -C /usr/local -xz
RUN cd /usr/local/go && patch -p1 < /work/go1.3.3-gccgo.patch
RUN cd /usr/local/go/src/cmd/go    && make install
RUN cd /usr/local/go/src/cmd/cgo   && make install
RUN cd /usr/local/go/src/cmd/gofmt && make install

WORKDIR /
