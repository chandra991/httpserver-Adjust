FROM ruby:latest
RUN apt update -y
RUN apt install libcap2-bin -y
COPY http_server.rb .
RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/ruby
CMD ruby http_server.rb
