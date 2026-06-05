FROM archlinux:base-devel-20260308.0.497099 AS builder

ARG GCC_VERSION
ARG SMARTCTL_VERSION

ARG GCC_SOURCE=https://mirrors.ocf.berkeley.edu/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.gz
ARG SMARTCTL_SOURCE=https://github.com/smartmontools/smartmontools/releases/download/v${SMARTCTL_VERSION}/smartmontools-${SMARTCTL_VERSION}.tar.gz

RUN pacman -Sy --noconfirm python >/dev/null

WORKDIR /build/gcc
RUN curl --silent --show-error --location --output gcc.tar.gz \
    "${GCC_SOURCE}" \
    && tar xf gcc.tar.gz --strip-components=1 \
    && ./contrib/download_prerequisites \
    && mkdir build && cd build \
    && ../configure \
        --prefix=/usr \
        --libdir=/usr/lib \
        --libexecdir=/usr/lib \
        --disable-multilib \
        --disable-bootstrap \
        --enable-languages=c,c++ \
    && make -j$(nproc) all-target-libgcc all-target-libstdc++-v3 \
    && mkdir -p /base/usr/lib && ln -s lib /base/usr/lib64 \
    && make install-target-libgcc DESTDIR=/base \
    && make install-target-libstdc++-v3 DESTDIR=/base

WORKDIR /build/smartctl
RUN SMARTCTL_SOURCE="$(sed -E 's/v([0-9]+)\.([0-9]+)/RELEASE_\1_\2/' <<<"$SMARTCTL_SOURCE")" \
    && curl --silent --show-error --location --output smartctl.tar.gz \
    "${SMARTCTL_SOURCE}" \
    && tar xf smartctl.tar.gz --strip-components=1 \
    && ./configure --prefix=/usr \
    && make -s -j$(nproc) \
    && make install DESTDIR=/base

RUN rm -fr /base/usr/lib/{pkgconfig,cmake,gcc} \
    && find /base/usr/lib -regextype posix-extended \
    -regex '.*\.(a|la|py|h|o)$' -delete

FROM ghcr.io/simons-containers/distroless-glibc:2.43

ARG GCC_VERSION
ARG SMARTCTL_VERSION

COPY --from=builder /base/usr/lib/ /usr/lib/
COPY --from=builder /base/usr/sbin/smartctl /usr/bin/

ENTRYPOINT ["/usr/bin/smartctl"]

LABEL org.opencontainers.image.title="distroless smartctl"
LABEL org.opencontainers.image.description="distroless smartctl"
LABEL org.opencontainers.image.version="${SMARTCTL_VERSION}"
LABEL org.opencontainers.image.source="https://github.com/simons-containers/distroless-smartctl"
LABEL org.opencontainers.image.base.libs="gcc@${GCC_VERSION}"
