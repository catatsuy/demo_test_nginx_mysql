FROM debian:jessie

ENV APP_ROOT /usr/src/app

WORKDIR $APP_ROOT

RUN apt update && apt install -y wget build-essential cpanminus

RUN wget https://github.com/cubicdaiya/nginx-build/releases/download/v0.10.0/nginx-build-linux-amd64-0.10.0.tar.gz && \
  tar xvf nginx-build-linux-amd64-0.10.0.tar.gz

RUN ./nginx-build -d work -openresty -pcre -openssl -zlib && cd work/openresty/1.11.2.3/openresty-1.11.2.3 && make install

ENV TEST_NGINX_BINARY /usr/local/openresty/bin/openresty

RUN echo "mysql-server mysql-server/root_password password password" | debconf-set-selections && \
   echo "mysql-server mysql-server/root_password_again password password" | debconf-set-selections && \
  apt install -y mysql-server

RUN apt install -y libmysqlclient-dev

RUN cpanm Test::Nginx DBI Test::mysqld

# COPY . $APP_ROOT

CMD ["prove", "-lv", "t"]
