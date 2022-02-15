FROM ubuntu:20.04

# Versions
ENV PATCH_NGINX_VERSION=1.16
ENV DEBIAN_FRONTEND=noninteractive
ENV NGINX_VERSION=${PATCH_NGINX_VERSION}.1 \
    QUICHE_REVISION=92dcc500462ac22bb72e822d3f4e99039d29acfd

RUN apt upgrade && apt update && \
    # Install requirements
    apt install -y curl git build-essential cmake golang-go libpcre3 libpcre3-dev zlib1g-dev net-tools
    # Install Rust
    # NOTE: Rust version is not fixed
RUN apt install -y wget iperf3
RUN mkdir -m777 /opt/rust /opt/cargo
ENV RUSTUP_HOME=/opt/rust CARGO_HOME=/opt/cargo PATH=/opt/cargo/bin:$PATH
RUN wget --https-only --secure-protocol=TLSv1_2 -O- https://sh.rustup.rs | sh /dev/stdin -y
RUN rustup target add x86_64-unknown-freebsd
RUN printf '#!/bin/sh\nexport CARGO_HOME=/opt/cargo\nexec /bin/sh "$@"\n' >/usr/local/bin/sh
RUN chmod +x /usr/local/bin/sh

RUN  curl https://sh.rustup.rs -sSf | sh -s -- -y && \
    PATH="/root/.cargo/bin:$PATH" && \
    mkdir build && cd build && \
     # Download Nginx
    curl https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar zx 
    # Get Quiche
COPY ./quiche /quiche
RUN cd /build && git clone https://github.com/matsumotory/ngx_custom_worker_module
RUN cd /build/nginx-${NGINX_VERSION} && \
   # Apply patch to Nginx
   patch -p01 < /quiche/nginx/nginx-1.16.patch && \
   # Configure
   ./configure                                 \
       --build="quiche-$(git --git-dir=/quiche/.git rev-parse --short HEAD)" \
       --with-http_ssl_module                  \
       --with-http_v2_module                   \
       --with-http_v3_module                   \
       --with-openssl=/quiche/quiche/deps/boringssl \
       --with-quiche=/quiche \
       --with-debug \
       --add-module=/build/ngx_custom_worker_module && \
   # Build Nginx
   make && \
   # Install Nginx
   make install && \
   rm -rf /build && \
   # Remove build requirements
   apt purge -y curl git build-essential cmake golang-go && \
   apt autoclean && apt clean && apt autoremove -y && \
   # Uninstall Rust
   # NOTE: `rustup self uninstall -y` causes 'error: No such file or directory (os error 2)'
   rm -rf $HOME/.cargo $HOME/.rustup && \
   rm -rf /var/lib/apt/lists/*

CMD ["/usr/local/nginx/sbin/nginx", "-g", "daemon off;"]