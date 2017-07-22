FROM debian:jessie

ENV APP_ROOT /usr/src/app

WORKDIR $APP_ROOT

ARG nginx_build_version="0.10.1"
ARG openresty_version="1.11.2.4"

RUN apt update && apt install -y wget build-essential cpanminus

RUN wget https://github.com/cubicdaiya/nginx-build/releases/download/v${nginx_build_version}/nginx-build-linux-amd64-${nginx_build_version}.tar.gz && \
  tar xvf nginx-build-linux-amd64-${nginx_build_version}.tar.gz

RUN ./nginx-build -d work -openresty -pcre -openssl -zlib && cd work/openresty/${openresty_version}/openresty-${openresty_version} && make install

ENV TEST_NGINX_BINARY /usr/local/openresty/bin/openresty

RUN echo "mysql-server mysql-server/root_password password password" | debconf-set-selections && \
   echo "mysql-server mysql-server/root_password_again password password" | debconf-set-selections && \
  apt install -y mysql-server

RUN apt install -y libmysqlclient-dev

RUN cpanm Test::Nginx DBI Test::mysqld

# COPY . $APP_ROOT

CMD ["prove", "-lv", "t"]
