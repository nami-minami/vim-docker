FROM rust:1.92 AS deno-builder
RUN export CARGO_TARGET_DIR=/tmp/
RUN apt-get update && apt-get install -y \
    cmake \
    librust-libsqlite3-sys-dev
RUN CARGO_HOME=/tmp cargo install deno@2.6.3 --locked

FROM ubuntu:24.04 AS vim-builder
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    lua5.4 \
    liblua5.4-dev \
    libperl-dev \
    python3-dev \
    ruby-dev
RUN git clone https://github.com/vim/vim /tmp/vim \
    --branch v9.1.2031 \
    --single-branch \
    --depth 1
WORKDIR /tmp/vim
RUN ./configure \
        --prefix=/usr/local \
        --enable-fail-if-missing \
        --enable-perlinterp \
        --enable-python3interp \
        --enable-luainterp \
        --enable-rubyinterp \
        --enable-terminal \
        --enable-multibyte
RUN make

FROM ubuntu:24.04
COPY --from=deno-builder /tmp/bin/deno /home/ubuntu/.cargo/bin/deno
COPY --from=vim-builder /tmp/vim/ /usr/local/src
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    build-essential \
    lua5.4 \
    liblua5.4-dev \
    libperl-dev \
    python3-dev \
    ruby-dev
WORKDIR /usr/local/src
RUN make install
RUN echo 'export PATH=$HOME/.cargo/bin:$PATH' >> /home/ubuntu/.bashrc
WORKDIR /home/ubuntu
CMD ["su", "ubuntu"]

