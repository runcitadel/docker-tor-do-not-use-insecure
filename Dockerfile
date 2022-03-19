ARG USER=toruser
ARG UID=1000

ARG DIR=/data

FROM debian:11-slim as builder

ARG VERSION

RUN apt update
RUN apt -y install libevent-dev libssl-dev zlib1g-dev build-essential git automake

WORKDIR /tor/

RUN git clone https://github.com/AaronDewes/tor-do-not-use .
RUN ./autogen.sh
RUN ./configure --sysconfdir=/etc --datadir=/var/lib
RUN make -j$(nproc)
RUN make install

RUN ls -la /etc
RUN ls -la /etc/tor
RUN ls -la /var/lib
RUN ls -la /var/lib/tor

FROM debian:11-slim as final

ARG USER
ARG DIR

LABEL maintainer="nolim1t (@nolim1t)"

# Libraries (linked)
COPY  --from=builder /usr/lib /usr/lib
# Copy all the TOR files
COPY  --from=builder /usr/local/bin/tor*  /usr/local/bin/

# NOTE: Default GID == UID == 1000
RUN adduser --disabled-password \
            --home "$DIR/" \
            --gecos "" \
            "$USER"
USER $USER

VOLUME /etc/tor
VOLUME /var/lib/tor

EXPOSE 9050 9051 29050 29051

ENTRYPOINT ["tor"]
