#!/bin/bash

apt update && apt install -y \
    build-essential \
    libpcre++-dev \
    libssl-dev \
    libgeoip-dev \
    libxslt1-dev \
    zlib1g-dev \
    libgd-dev \
    libmaxminddb0 \
    libmaxminddb-dev \
    mmdb-bin

wget https://nginx.org/download/nginx-1.27.3.tar.gz

tar -xvf nginx-1.27.3.tar.gz
cd nginx-1.27.3

./configure --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf \
    --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log \
    --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules \
    --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi \
    --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-debug --with-compat --with-pcre-jit \
    --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module \
    --with-http_auth_request_module --with-http_v2_module --with-http_dav_module \
    --with-http_slice_module --with-threads --with-http_addition_module --with-http_gunzip_module \
    --with-http_gzip_static_module --with-http_image_filter_module=dynamic --with-http_sub_module \
    --with-http_xslt_module=dynamic --with-stream=dynamic --with-stream_ssl_module \
    --with-mail=dynamic --with-mail_ssl_module --with-http_mp4_module \
    --add-dynamic-module=../nginx-geoip-module --add-dynamic-module=../nginx-geoip2-module

make
make install

cat > /etc/systemd/system/nginx.service <<EOF
[Unit]
Description=The NGINX HTTP and reverse proxy server
After=syslog.target network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/etc/nginx/nginx.pid
ExecStartPre=/usr/sbin/nginx -t
ExecStart=/usr/sbin/nginx
ExecReload=/usr/sbin/nginx -s reload
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl start nginx
systemctl enable nginx

rm -Rf nginx-*